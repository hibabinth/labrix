import 'package:flutter/material.dart';
import '../../../data/models/announcement_model.dart';
import '../../../core/theme/app_colors.dart';

class AnnouncementBanner extends StatefulWidget {
  final List<AnnouncementModel> announcements;

  const AnnouncementBanner({super.key, required this.announcements});

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner> {
  int _currentIndex = 0;
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || widget.announcements.isEmpty) return const SizedBox.shrink();

    final ann = widget.announcements[_currentIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondaryColor, Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ann.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ann.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _isVisible = false),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (widget.announcements.length > 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 12),
                    onPressed: () {
                      setState(() {
                        _currentIndex = (_currentIndex - 1 + widget.announcements.length) % widget.announcements.length;
                      });
                    },
                  ),
                  Text(
                    '${_currentIndex + 1}/${widget.announcements.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                    onPressed: () {
                      setState(() {
                        _currentIndex = (_currentIndex + 1) % widget.announcements.length;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
