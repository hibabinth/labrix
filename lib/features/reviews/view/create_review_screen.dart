import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/review_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../viewmodel/review_viewmodel.dart';

class CreateReviewScreen extends StatefulWidget {
  final BookingModel booking;
  const CreateReviewScreen({super.key, required this.booking});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating first.')),
      );
      return;
    }

    final reviewVM = Provider.of<ReviewViewModel>(context, listen: false);
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    final review = ReviewModel(
      id: const Uuid().v4(),
      bookingId: widget.booking.id,
      reviewerId: currentUserId,
      workerId: widget.booking.workerId,
      rating: _rating,
      comment: _commentController.text,
      createdAt: DateTime.now(),
    );

    final success = await reviewVM.leaveReview(review);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reviewVM.error ?? 'Failed to submit review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Leave Feedback',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How was the service?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking #${widget.booking.id.substring(0, 6)}',
              style: const TextStyle(color: AppColors.textSecondaryColor),
            ),
            const SizedBox(height: 32),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() => _rating = index + 1);
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Additional Comments (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            Consumer<ReviewViewModel>(
              builder: (context, vm, _) {
                return CustomButton(
                  text: 'Submit Review',
                  isLoading: vm.isLoading,
                  onPressed: _submitFeedback,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
