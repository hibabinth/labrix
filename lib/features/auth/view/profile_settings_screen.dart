import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../posts/view/create_post_screen.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/models/post_model.dart';
import 'edit_profile_screen.dart';
import 'splash_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    final profile = profileVM.currentProfile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.textPrimaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.errorColor),
            onPressed: () async {
              profileVM.clearProfile();
              await authVM.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Cover and Avatar Section
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Cover Photo
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        image: profile.coverImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(profile.coverImageUrl!), 
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profile.coverImageUrl == null
                          ? const Center(
                              child: Icon(Icons.panorama, color: Colors.grey, size: 40),
                            )
                          : null,
                    ),
                  ),
                  // Avatar Photo with Edit Overlay
                  Positioned(
                    bottom: 0,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                            backgroundImage: profile.imageUrl != null 
                                ? NetworkImage(profile.imageUrl!) 
                                : null,
                            child: profile.imageUrl == null
                                ? const Icon(Icons.person, size: 40, color: AppColors.primaryColor)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(profile: profile),
                                ),
                              ).then((_) {
                                if (authVM.currentUser?.id != null) {
                                  profileVM.loadProfile(authVM.currentUser!.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Name and Headline
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            if (profile.headline != null && profile.headline!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                profile.headline!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else if (profile.role == 'worker') ...[
              const SizedBox(height: 8),
              const Text(
                'Worker Profile',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(profile.followers.toString(), 'Followers'),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatColumn(profile.following.toString(), 'Following'),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatColumn('10', 'Events'),
              ],
            ),
            const SizedBox(height: 40),

            // About Me
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Me',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.aboutMe ?? 'I am passionate about what I do and always strive to deliver the best quality of work. I love learning new things and improving my skills over time.',
                  style: const TextStyle(height: 1.5, color: AppColors.textSecondaryColor),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(' Read More', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Posts Gallery Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Posts',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box, color: AppColors.primaryColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                        ).then((value) {
                          if (value == true) {
                            // Force rebuild to fetch new posts
                            (context as Element).markNeedsBuild();
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<PostModel>>(
                  future: PostRepository().getUserPosts(profile.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('No posts yet.', style: TextStyle(color: AppColors.textSecondaryColor)),
                        ),
                      );
                    }
                    
                    final posts = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: post.imageUrl != null
                                ? DecorationImage(image: NetworkImage(post.imageUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: post.imageUrl == null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      post.text,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
