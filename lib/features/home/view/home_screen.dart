import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/category_tile.dart';
import '../widgets/worker_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).initHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_pin,
              color: AppColors.primaryColor,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: homeVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: homeVM.initHome,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(homeVM),
                    const SizedBox(height: 24),
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryList(homeVM),
                    const SizedBox(height: 24),
                    const Text(
                      'Nearby Workers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWorkerList(homeVM),
                  ],
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
        hintText: 'Search for services...',
        hintStyle: const TextStyle(color: AppColors.textSecondaryColor),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryList(HomeViewModel homeVM) {
    if (homeVM.categories.isEmpty)
      return const Text('No categories available.');
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: homeVM.categories.length,
        itemBuilder: (context, index) {
          final cat = homeVM.categories[index];
          final isSelected = _selectedCategory == cat.name;
          return CategoryTile(
            categoryName: cat.name,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedCategory = isSelected ? null : cat.name;
              });
              homeVM.filterWorkers(_searchQuery, _selectedCategory);
            },
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
            'No workers found.',
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
