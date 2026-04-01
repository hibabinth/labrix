import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../widgets/worker_card.dart';
import '../../../shared/widgets/announcement_banner.dart';
import 'category_detail_screen.dart';
import 'category_screen.dart';
import '../../../shared/widgets/notification_bell.dart';
import 'worker_map_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
        await profileVM.loadProfile(userId);
        
        if (mounted) {
          final profile = profileVM.currentProfile;
          Provider.of<HomeViewModel>(context, listen: false).initHome(profile?.role);
        }
      } else {
        Provider.of<HomeViewModel>(context, listen: false).initHome('user');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    final profile = profileVM.currentProfile;
    final userName = profile?.name.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: homeVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final role = profileVM.currentProfile?.role;
                await homeVM.initHome(role);
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) {
                  await profileVM.loadProfile(userId);
                }
              },
              color: AppColors.primaryColor,
              child: CustomScrollView(
                slivers: [
                  // ── Premium Collapsible Header ───────────────────
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    actions: const [
                      NotificationBell(),
                      SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeaderBackground(userName, profile),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(80),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: _buildSearchBar(homeVM),
                      ),
                    ),
                  ),

                  // ── Announcements ────────────────────────────────
                  if (homeVM.announcements.isNotEmpty)
                    SliverToBoxAdapter(
                      child: AnnouncementBanner(announcements: homeVM.announcements),
                    ),

                  // ── Main Content ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Categories
                          _buildSectionHeader(
                            'Categories',
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CategoryScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryList(homeVM),

                          const SizedBox(height: 32),

                          // Popular Workers
                          _buildSectionHeader(
                            'Specialty Services',
                            onSeeAll: () {},
                          ),
                          const SizedBox(height: 16),
                          _buildWorkerList(homeVM),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkerMapScreen()),
          );
        },
        backgroundColor: AppColors.secondaryColor,
        icon: const Icon(Icons.map_outlined, color: Colors.white),
        label: const Text(
          'Map View',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeaderBackground(String userName, profile) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        // Abstract shapes
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        // Greeting Text
        Positioned(
          left: 20,
          right: 20,
          top: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: profile?.imageUrl != null
                        ? NetworkImage(profile!.imageUrl!)
                        : null,
                    child: profile?.imageUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hello, $userName! 👋',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Find your best\nservice professional',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(HomeViewModel homeVM) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() => _searchQuery = val);
          homeVM.filterWorkers(_searchQuery, _selectedCategory);
        },
        decoration: InputDecoration(
          hintText: 'Search for electrican, plumber...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    homeVM.filterWorkers('', _selectedCategory);
                  },
                )
              : Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune,
                      color: AppColors.primaryColor, size: 18),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(HomeViewModel homeVM) {
    final cats = homeVM.categories;
    if (cats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('No categories available.'),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = cats[index];
          final isSelected = _selectedCategory == cat.name;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = isSelected ? null : cat.name;
              });
              homeVM.filterWorkers(_searchQuery, _selectedCategory);
              if (!isSelected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryDetailScreen(category: cat),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 90,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColors.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkerList(HomeViewModel homeVM) {
    if (homeVM.filteredWorkers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No services found.',
            style: TextStyle(color: AppColors.textSecondaryColor),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: homeVM.filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = homeVM.filteredWorkers[index];
        return WorkerCard(worker: worker);
      },
    );
  }
}

