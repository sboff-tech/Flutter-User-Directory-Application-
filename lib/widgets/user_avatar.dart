import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.large = false});

  final User user;
  final bool large;

  @override
  Widget build(BuildContext context) {
    const backgrounds = [
      Color(0xFFDDF2EB),
      Color(0xFFE2EBFA),
      Color(0xFFF8EADB),
      Color(0xFFECE5F6),
    ];
    return Container(
      width: large ? 76 : 48,
      height: large ? 76 : 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgrounds[(user.id - 1) % backgrounds.length],
        borderRadius: BorderRadius.circular(large ? 25 : 16),
      ),
      child: Text(
        user.initials,
        style: TextStyle(
          color: AppTheme.ink,
          fontWeight: FontWeight.w700,
          fontSize: large ? 27 : 17,
        ),
      ),
    );
  }
}
