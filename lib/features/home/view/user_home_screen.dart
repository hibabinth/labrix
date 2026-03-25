import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../widgets/worker_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).initHome();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        Provider.of<ProfileViewModel>(context, listen: false).loadProfile(userId);
      }
    });
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
                await homeVM.initHome();
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) {
                  await profileVM.loadProfile(userId);
                }
              },
              color: AppColors.primaryColor,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                child: const Icon(Icons.person, color: AppColors.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome',
                                    style: TextStyle(
                                      color: AppColors.textSecondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              color: AppColors.textPrimaryColor,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Hero Text
                      const Text(
                        'All your services\nin one place',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Search Bar
                      _buildSearchBar(homeVM),
                      const SizedBox(height: 32),
                      
                      // Category Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Categories List
                      _buildCategoryList(homeVM),
                      
                      const SizedBox(height: 32),
                      
                      // Specialty Services Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Specialty services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Workers List
                      _buildWorkerList(homeVM),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBar(HomeViewModel homeVM) {
    return TextField(
      onChanged: (val) {
        setState(() => _searchQuery = val);
        homeVM.filterWorkers(_searchQuery, _selectedCategory);
      },
      decoration: InputDecoration(
        hintText: 'Your search',
        hintStyle: const TextStyle(color: AppColors.textSecondaryColor),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondaryColor,
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.tune,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryList(HomeViewModel homeVM) {
    if (homeVM.categories.isEmpty) return const Text('No categories available.');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: homeVM.categories.length > 4 ? 4 : homeVM.categories.length,
      itemBuilder: (context, index) {
        final cat = homeVM.categories[index];
        final isSelected = _selectedCategory == cat.name;
        
        // Use a default icon based on category if no image
        IconData catIcon = Icons.home_repair_service;
        if (cat.name.toLowerCase().contains('plumbing')) catIcon = Icons.plumbing;
        if (cat.name.toLowerCase().contains('electric')) catIcon = Icons.electrical_services;
        if (cat.name.toLowerCase().contains('cleaning')) catIcon = Icons.cleaning_services;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : cat.name;
            });
            homeVM.filterWorkers(_searchQuery, _selectedCategory);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  catIcon,
                  size: 40,
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
