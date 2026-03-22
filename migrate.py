import os
import shutil

src_dest_map = {
    'lib/models/profile_model.dart': 'lib/data/models/profile_model.dart',
    'lib/models/worker_model.dart': 'lib/data/models/worker_model.dart',
    'lib/repository/auth_repository.dart': 'lib/data/repositories/auth_repository.dart',
    'lib/repository/profile_repository.dart': 'lib/data/repositories/profile_repository.dart',
    'lib/view_models/auth_view_model.dart': 'lib/features/auth/viewmodel/auth_viewmodel.dart',
    'lib/view_models/profile_view_model.dart': 'lib/features/auth/viewmodel/profile_viewmodel.dart',
    'lib/views/auth/login_screen.dart': 'lib/features/auth/view/login_screen.dart',
    'lib/views/auth/signup_screen.dart': 'lib/features/auth/view/signup_screen.dart',
    'lib/views/auth/otp_screen.dart': 'lib/features/auth/view/otp_screen.dart',
    'lib/views/profile/role_selection_screen.dart': 'lib/features/auth/view/role_selection_screen.dart',
    'lib/views/profile/user_profile_setup_screen.dart': 'lib/features/user/view/user_profile_setup_screen.dart',
    'lib/views/profile/worker_profile_setup_screen.dart': 'lib/features/worker/view/worker_profile_setup_screen.dart',
    'lib/views/splash_screen.dart': 'lib/features/auth/view/splash_screen.dart',
    'lib/res/app_colors.dart': 'lib/core/theme/app_colors.dart',
    'lib/res/components/custom_textfield.dart': 'lib/shared/widgets/custom_textfield.dart',
    'lib/res/components/custom_button.dart': 'lib/shared/widgets/custom_button.dart',
}

import_replacements = [
    # In views components
    ("import '../app_colors.dart';", "import '../../core/theme/app_colors.dart';"),
    ("import '../../res/components/custom_textfield.dart';", "import '../../../shared/widgets/custom_textfield.dart';"),
    ("import '../../res/components/custom_button.dart';", "import '../../../shared/widgets/custom_button.dart';"),
    ("import '../../res/app_colors.dart';", "import '../../../core/theme/app_colors.dart';"),
    ("import '../res/app_colors.dart';", "import '../../../core/theme/app_colors.dart';"),

    # In view models
    ("import '../../repository/auth_repository.dart';", "import '../../../data/repositories/auth_repository.dart';"),
    ("import '../repository/auth_repository.dart';", "import '../../../data/repositories/auth_repository.dart';"),
    ("import '../../repository/profile_repository.dart';", "import '../../../data/repositories/profile_repository.dart';"),
    ("import '../repository/profile_repository.dart';", "import '../../../data/repositories/profile_repository.dart';"),
    ("import '../../models/profile_model.dart';", "import '../../../data/models/profile_model.dart';"),
    ("import '../models/profile_model.dart';", "import '../../../data/models/profile_model.dart';"),
    ("import '../../models/worker_model.dart';", "import '../../../data/models/worker_model.dart';"),
    ("import '../models/worker_model.dart';", "import '../../../data/models/worker_model.dart';"),
    ("import 'profile_model.dart';", "import 'profile_model.dart';"),

    # In views
    ("import '../../view_models/auth_view_model.dart';", "import '../viewmodel/auth_viewmodel.dart';"),
    ("import '../view_models/auth_view_model.dart';", "import '../viewmodel/auth_viewmodel.dart';"),
    ("import '../../view_models/profile_view_model.dart';", "import '../viewmodel/profile_viewmodel.dart';"),
    ("import '../view_models/profile_view_model.dart';", "import '../viewmodel/profile_viewmodel.dart';"),
    
    # Internal View Routing
    ("import 'auth/login_screen.dart';", "import 'login_screen.dart';"),
    ("import 'profile/role_selection_screen.dart';", "import 'role_selection_screen.dart';"),
    ("import 'user_profile_setup_screen.dart';", "import '../../user/view/user_profile_setup_screen.dart';"),
    ("import 'worker_profile_setup_screen.dart';", "import '../../worker/view/worker_profile_setup_screen.dart';"),

    # In Main.dart
    ("import 'view_models/auth_view_model.dart';", "import 'features/auth/viewmodel/auth_viewmodel.dart';"),
    ("import 'view_models/profile_view_model.dart';", "import 'features/auth/viewmodel/profile_viewmodel.dart';"),
    ("import 'views/splash_screen.dart';", "import 'features/auth/view/splash_screen.dart';"),
]

for src, dest in src_dest_map.items():
    if os.path.exists(src):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(src, 'r', encoding='utf-8') as f:
            content = f.read()
        
        for old, new in import_replacements:
            content = content.replace(old, new)
        
        with open(dest, 'w', encoding='utf-8') as f:
            f.write(content)

main_file = 'lib/main.dart'
if os.path.exists(main_file):
    with open(main_file, 'r', encoding='utf-8') as f:
        content = f.read()
    for old, new in import_replacements:
        content = content.replace(old, new)
    with open(main_file, 'w', encoding='utf-8') as f:
        f.write(content)

for folder in ['lib/models', 'lib/repository', 'lib/view_models', 'lib/views', 'lib/res']:
    if os.path.exists(folder):
        shutil.rmtree(folder)

print("Migration completed.")
