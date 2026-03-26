import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        post.createdAt.toLocal().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: post.imageUrl != null
          ? _buildImagePost(context, dateStr)
          : _buildTextPost(context, dateStr),
    );
  }

  // ── Image post: full-screen image + bottom caption sheet ──
  Widget _buildImagePost(BuildContext context, String dateStr) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full image
        InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.network(
            post.imageUrl!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
            ),
          ),
        ),

        // Bottom caption overlay
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.82),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (post.text.isNotEmpty)
                  Text(
                    post.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Text-only post: white card on dark background ──
  Widget _buildTextPost(BuildContext context, String dateStr) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.85),
            Colors.black87,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 100),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_quote,
                color: AppColors.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                post.text,
                style: const TextStyle(
                  fontSize: 17,
                  color: AppColors.textPrimaryColor,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
