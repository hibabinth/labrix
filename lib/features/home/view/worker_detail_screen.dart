import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/worker_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../booking/view/create_booking_screen.dart';
import '../../reviews/viewmodel/review_viewmodel.dart';
import '../../../data/models/review_model.dart';
import 'package:intl/intl.dart';

class WorkerDetailScreen extends StatefulWidget {
  final WorkerModel worker;
  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewViewModel>(context, listen: false)
          .loadWorkerReviews(widget.worker.id);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ── Hero Header ───────────────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                centerTitle: true,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final double top = constraints.biggest.height;
                    // expandedHeight (280)
                    final double collapseProgress = ((280 - top) / (280 - kToolbarHeight)).clamp(0.0, 1.0);
                    
                    return Stack(
                      children: [
                        Opacity(
                          opacity: (1.0 - (collapseProgress * 2)).clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildAvatar(worker),
                                const SizedBox(width: 14),
                                _buildNameAndCategory(worker),
                              ],
                            ),
                          ),
                        ),
                        if (collapseProgress > 0.8)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                worker.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                background: _buildHeroBackground(worker),
              ),
            ),

            // ── Body ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating
                      Consumer<ReviewViewModel>(
                        builder: (context, reviewVM, _) {
                          if (reviewVM.isLoading) {
                            return const SizedBox.shrink();
                          }
                          return _buildRatingBanner(reviewVM);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Quick stats row
                      _buildStatsRow(worker),
                      const SizedBox(height: 28),

                      // Category & Subcategory
                      _buildSectionLabel('Specialisation'),
                      const SizedBox(height: 10),
                      _buildCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.work_outline,
                                  color: AppColors.primaryColor),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryColor,
                                    fontSize: 15,
                                  ),
                                ),
                                if (worker.subcategory != null &&
                                    worker.subcategory!.isNotEmpty)
                                  Text(
                                    worker.subcategory!,
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            if (worker.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified,
                                        color: Colors.green, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contact details
                      _buildSectionLabel('Contact & Details'),
                      const SizedBox(height: 10),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildDetailRow(Icons.location_on_outlined,
                                worker.location),
                            _buildDivider(),
                            _buildDetailRow(
                                Icons.phone_outlined, worker.phone),
                            _buildDivider(),
                            _buildDetailRow(Icons.attach_money,
                                'Rate: ${worker.priceRange}'),
                            _buildDivider(),
                            _buildDetailRow(
                                Icons.access_time, 'Hours: ${worker.workingStart} - ${worker.workingEnd}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Skills
                      if (worker.skills.isNotEmpty) ...[
                        _buildSectionLabel('Skills'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: worker.skills
                              .map(
                                (s) => Chip(
                                  label: Text(s,
                                      style: const TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  backgroundColor:
                                      AppColors.primaryColor.withValues(alpha: 0.1),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Book Service',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreateBookingScreen(
                                        worker: widget.worker),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Reviews
                      _buildSectionLabel('Reviews'),
                      const SizedBox(height: 10),
                      Consumer<ReviewViewModel>(
                        builder: (context, reviewVM, _) {
                          if (reviewVM.workerReviews.isEmpty) {
                            return _buildCard(
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'No reviews yet.',
                                    style: TextStyle(
                                        color: AppColors.textSecondaryColor),
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviewVM.workerReviews.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final review = reviewVM.workerReviews[index];
                              return _buildReviewCard(review, index);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBackground(WorkerModel worker) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.65),
              ],
            ),
          ),
        ),
        // Soft shape decoration
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Dark scrim at bottom
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(WorkerModel worker) {
    return Hero(
      tag: 'worker_avatar_${worker.id}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.3),
          backgroundImage:
              worker.imageUrl != null ? NetworkImage(worker.imageUrl!) : null,
          child: worker.imageUrl == null
              ? const Icon(Icons.person, size: 38, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildNameAndCategory(WorkerModel worker) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            worker.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            worker.category,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBanner(ReviewViewModel reviewVM) {
    final rating = reviewVM.averageRating;
    final total = reviewVM.workerReviews.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.amber.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : 'Not rated',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          if (total > 0) ...[
            const SizedBox(width: 6),
            Text(
              '($total review${total > 1 ? 's' : ''})',
              style: TextStyle(color: Colors.amber.shade700, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(WorkerModel worker) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_outlined,
            value: '${worker.experienceYears}',
            unit: 'yrs exp',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.circle,
            value: worker.isOnline ? 'On Duty' : 'Away',
            unit: 'status',
            color: worker.isOnline ? Colors.green : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            value: worker.priceRange.split(' ').first,
            unit: 'rate',
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.grey.shade100, height: 1);

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                backgroundImage: (review.reviewerImageUrl != null && review.reviewerImageUrl!.isNotEmpty)
                    ? NetworkImage(review.reviewerImageUrl!)
                    : null,
                child: (review.reviewerImageUrl == null || review.reviewerImageUrl!.isEmpty)
                    ? Text(
                        review.reviewerName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName ?? 'Labrix User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star_rounded,
                          color: i < review.rating ? Colors.amber : Colors.grey.shade200,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM dd').format(review.createdAt),
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                color: AppColors.textPrimaryColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
