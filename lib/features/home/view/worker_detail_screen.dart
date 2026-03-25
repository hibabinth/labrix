import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/worker_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../booking/view/create_booking_screen.dart';
import '../../reviews/viewmodel/review_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/profile_repository.dart';

class WorkerDetailScreen extends StatefulWidget {
  final WorkerModel worker;
  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  bool _isFollowing = false;
  bool _isProcessingFollow = false;

  void _toggleFollow() async {
    setState(() => _isProcessingFollow = true);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) {
      setState(() => _isProcessingFollow = false);
      return;
    }
    
    final repo = ProfileRepository();
    bool success;
    if (_isFollowing) {
      success = await repo.unfollowUser(widget.worker.id, currentUserId);
    } else {
      success = await repo.followUser(widget.worker.id, currentUserId);
    }
    
    if (success && mounted) {
      setState(() => _isFollowing = !_isFollowing);
    }
    if (mounted) setState(() => _isProcessingFollow = false);
  }

  void _showRatingDialog() {
    double currentSelectedRating = 5.0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Rate Worker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How would you rate ${widget.worker.name}?'),
              const SizedBox(height: 16),
              Slider(
                value: currentSelectedRating,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                activeColor: Colors.amber,
                label: currentSelectedRating.toString(),
                onChanged: (val) => setStateDialog(() => currentSelectedRating = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel')
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              onPressed: () async {
                final success = await ProfileRepository().rateWorker(widget.worker.id, currentSelectedRating);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating saved!')));
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewViewModel>(
        context,
        listen: false,
      ).loadWorkerReviews(widget.worker.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Worker Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rate, color: Colors.amber),
            onPressed: _showRatingDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                widget.worker.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.worker.category,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ReviewViewModel>(
              builder: (context, reviewVM, _) {
                if (reviewVM.isLoading)
                  return const Center(child: CircularProgressIndicator());

                final rating = reviewVM.averageRating;
                final total = reviewVM.workerReviews.length;

                return Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'No Ratings',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (total > 0)
                        Text(
                          ' ($total reviews)',
                          style: const TextStyle(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Details & Contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              children: [
                _buildDetailRow(
                  Icons.timer,
                  'Experience: ${widget.worker.experienceYears} years',
                ),
                const Divider(),
                _buildDetailRow(
                  Icons.attach_money,
                  'Rate: ${widget.worker.priceRange}',
                ),
                const Divider(),
                _buildDetailRow(
                  Icons.location_on,
                  'Location: ${widget.worker.location}',
                ),
                const Divider(),
                _buildDetailRow(Icons.phone, 'Phone: ${widget.worker.phone}'),
                const Divider(),
                _buildDetailRow(
                  widget.worker.isVerified
                      ? Icons.verified
                      : Icons.error_outline,
                  widget.worker.isVerified
                      ? 'Verified Professional'
                      : 'Not Verified',
                  color: widget.worker.isVerified
                      ? AppColors.successColor
                      : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Book Service',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateBookingScreen(worker: widget.worker),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isProcessingFollow ? null : _toggleFollow,
                    child: _isProcessingFollow
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isFollowing ? 'Following' : 'Follow', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ReviewViewModel>(
              builder: (context, reviewVM, _) {
                if (reviewVM.workerReviews.isEmpty) {
                  return const Text(
                    'This worker has no reviews yet.',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewVM.workerReviews.length,
                  itemBuilder: (context, index) {
                    final review = reviewVM.workerReviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              review.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle:
                            review.comment != null && review.comment!.isNotEmpty
                            ? Text(review.comment!)
                            : const Text('No written comment.'),
                        trailing: Text(
                          review.createdAt.toLocal().toString().split(' ')[0],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text, {
    Color color = AppColors.textPrimaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
