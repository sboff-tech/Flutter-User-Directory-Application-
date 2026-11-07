import 'package:flutter/material.dart';

import 'screens/user_list_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const UserDirectoryApp());

class UserDirectoryApp extends StatelessWidget {
  const UserDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Directory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const UserListScreen(),
    );
  }
}
