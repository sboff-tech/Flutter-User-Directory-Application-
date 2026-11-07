import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.isLoading = false,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isLoading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0EFEA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppTheme.teal, size: 38),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (isLoading)
                      Semantics(
                        label: 'Loading users',
                        child: const CircularProgressIndicator(),
                      ),
                    ?action,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
