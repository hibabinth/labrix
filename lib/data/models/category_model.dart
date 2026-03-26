class CategoryModel {
  final int id;
  final String name;
  final String emoji;
  final List<String> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.emoji = '🔧',
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'] ?? '🔧',
      subcategories: List<String>.from(json['subcategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'subcategories': subcategories,
    };
  }
}

/// Static local taxonomy — no Supabase round-trip needed for the category list.
class WorkerCategory {
  static final List<CategoryModel> all = [
    CategoryModel(
      id: 1,
      name: 'Construction',
      emoji: '🔨',
      subcategories: [
        'Mason',
        'Carpenter',
        'Electrician',
        'Plumber',
        'Painter',
        'Tile Worker',
        'Welder',
      ],
    ),
    CategoryModel(
      id: 2,
      name: 'General Labour',
      emoji: '🧱',
      subcategories: [
        'Helper / Coolie',
        'Loading & Unloading',
        'Site Helper',
        'Farm Labour',
      ],
    ),
    CategoryModel(
      id: 3,
      name: 'Home Services',
      emoji: '🏠',
      subcategories: [
        'House Maid',
        'Cleaning Staff',
        'Babysitter',
        'Caretaker',
        'Home Nurse',
        'Cook',
      ],
    ),
    CategoryModel(
      id: 4,
      name: 'Repair & Maintenance',
      emoji: '🔧',
      subcategories: [
        'AC Repair',
        'Appliance Repair',
        'Plumbing Fix',
        'Electrical Repair',
        'Furniture Repair',
      ],
    ),
    CategoryModel(
      id: 5,
      name: 'Industrial',
      emoji: '🏭',
      subcategories: [
        'Factory Worker',
        'Warehouse Staff',
        'Packing Worker',
        'Delivery Helper',
        'Office Boy',
      ],
    ),
    CategoryModel(
      id: 6,
      name: 'Transport',
      emoji: '🚚',
      subcategories: [
        'Driver',
        'Packers & Movers',
        'Loader',
      ],
    ),
    CategoryModel(
      id: 7,
      name: 'Security',
      emoji: '🛡️',
      subcategories: [
        'Security Guard',
        'Watchman',
        'Housekeeping (Office)',
        'Housekeeping (Mall)',
      ],
    ),
    CategoryModel(
      id: 8,
      name: 'Event Services',
      emoji: '🎉',
      subcategories: [
        'Event Setup',
        'Catering Helper',
        'Cleaning Crew',
      ],
    ),
    CategoryModel(
      id: 9,
      name: 'Outdoor & Other',
      emoji: '🌿',
      subcategories: [
        'Gardening',
        'Landscaping',
        'Well Cleaning',
        'Tree Cutting',
      ],
    ),
  ];
}
