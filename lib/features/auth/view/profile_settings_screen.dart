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

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
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
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ── Collapsible Header ─────────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Edit Profile',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile),
                      ),
                    ).then((_) {
                      if (authVM.currentUser?.id != null) {
                        profileVM.loadProfile(authVM.currentUser!.id);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  tooltip: 'Sign Out',
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
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildSliverBackground(profile),
              ),
            ),

            // ── Body Content ──────────────────────────────────────
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info chips row
                      _buildInfoChips(profile),
                      const SizedBox(height: 28),

                      // About Me
                      if (profile.aboutMe != null &&
                          profile.aboutMe!.isNotEmpty) ...[
                        _buildSectionLabel('About Me'),
                        const SizedBox(height: 10),
                        _buildCard(
                          child: Text(
                            profile.aboutMe!,
                            style: const TextStyle(
                              height: 1.6,
                              color: AppColors.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Role badge
                      if (profile.role == 'worker') ...[
                        _buildSectionLabel('Role'),
                        const SizedBox(height: 10),
                        _buildCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.engineering,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Worker / Service Provider',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Posts
                      _buildPostsSection(context, profile.id),
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

  Widget _buildSliverBackground(profile) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover
        profile.coverImageUrl != null
            ? Image.network(profile.coverImageUrl!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
        // Dark scrim
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
            ),
          ),
        ),
        // Avatar + name at bottom
        Positioned(
          left: 20,
          bottom: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Hero(
                tag: 'profile_avatar_${profile.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor:
                        AppColors.primaryColor.withValues(alpha: 0.2),
                    backgroundImage: profile.imageUrl != null
                        ? NetworkImage(profile.imageUrl!)
                        : null,
                    child: profile.imageUrl == null
                        ? const Icon(Icons.person,
                            size: 36, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black54),
                        ],
                      ),
                    ),
                    if (profile.headline != null &&
                        profile.headline!.isNotEmpty)
                      Text(
                        profile.headline!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(profile) {
    final chips = <_InfoChip>[];
    if (profile.location.isNotEmpty) {
      chips.add(_InfoChip(icon: Icons.location_on_outlined, label: profile.location));
    }
    if (profile.phone.isNotEmpty) {
      chips.add(_InfoChip(icon: Icons.phone_outlined, label: profile.phone));
    }
    if (profile.dob != null && profile.dob!.isNotEmpty) {
      chips.add(_InfoChip(icon: Icons.cake_outlined, label: profile.dob!));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: chips.map((c) => _buildChipWidget(c)).toList(),
    );
  }

  Widget _buildChipWidget(_InfoChip chip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 15, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            chip.label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPostsSection(BuildContext context, String profileId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Posts'),
            Material(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                  ).then((_) => setState(() {}));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 18, color: AppColors.primaryColor),
                      SizedBox(width: 4),
                      Text(
                        'New Post',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<PostModel>>(
          future: PostRepository().getUserPosts(profileId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                      color: AppColors.primaryColor),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildCard(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined,
                            size: 36, color: AppColors.textSecondaryColor),
                        SizedBox(height: 8),
                        Text(
                          'No posts yet. Share your first!',
                          style:
                              TextStyle(color: AppColors.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
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
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300 + index * 60),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                        ),
                      ],
                      image: post.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(post.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: post.imageUrl == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                post.text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _InfoChip {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
}
