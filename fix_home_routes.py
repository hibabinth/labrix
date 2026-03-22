import os

files_to_fix = [
    'lib/features/auth/view/login_screen.dart',
    'lib/features/auth/view/otp_screen.dart',
    'lib/features/auth/view/splash_screen.dart',
    'lib/features/user/view/user_profile_setup_screen.dart',
    'lib/features/worker/view/worker_profile_setup_screen.dart'
]

# Path to the actual home screen relative from the corresponding feature views:
# auth/view/ -> ../../home/view/home_screen.dart
# user/view/ -> ../../home/view/home_screen.dart
# worker/view/ -> ../../home/view/home_screen.dart

for file in files_to_fix:
    if os.path.exists(file):
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace the literal Scaffold
        target_str1 = "const Scaffold(body: Center(child: Text('Home Screen')))"
        target_str2 = "const Scaffold(body: Center(child: Text('Home'))) "
        
        if target_str1 in content or target_str2 in content:
            content = content.replace(target_str1, "const HomeScreen()")
            content = content.replace(target_str2, "const HomeScreen()")
            
            # Add import 
            import_statement = "import '../../home/view/home_screen.dart';"
            if import_statement not in content:
                # Add at the top where other imports are
                lines = content.split('\n')
                for i, line in enumerate(lines):
                    if line.startswith('import '):
                        # Insert after last import is fine, or just immediately.
                        pass
                # A safer way is just insert after flutter/material.dart
                content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_statement)
                
            with open(file, 'w', encoding='utf-8') as f:
                f.write(content)

print('Routes replaced successfully.')
