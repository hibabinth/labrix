import os

files_to_fix = [
    'lib/features/auth/view/login_screen.dart',
    'lib/features/auth/view/otp_screen.dart',
    'lib/features/auth/view/splash_screen.dart',
    'lib/features/user/view/user_profile_setup_screen.dart',
    'lib/features/worker/view/worker_profile_setup_screen.dart'
]

for file in files_to_fix:
    if os.path.exists(file):
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        content = content.replace("const HomeScreen()", "const MainScreen()")
        content = content.replace("import '../../home/view/home_screen.dart';", "import '../../home/view/main_screen.dart';")
            
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)

print('Routes switched to MainScreen successfully.')
