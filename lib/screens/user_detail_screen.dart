import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});
  final User user;

  void _copyContact(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${user.name}\n${user.email}\n${user.phone}\n${user.website}',
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contact details copied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact details'),
        actions: [
          IconButton(
            tooltip: 'Copy contact details',
            onPressed: () => _copyContact(context),
            icon: const Icon(Icons.copy_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      children: [
                        UserAvatar(user: user, large: true),
                        const SizedBox(height: 18),
                        Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '@${user.username}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.teal,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.company.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _section('Contact information', Icons.alternate_email_rounded, [
                  _detail('Username', user.username),
                  _detail('Email', user.email),
                  _detail('Phone', user.phone),
                  _detail('Website', user.website, accent: true),
                ]),
                const SizedBox(height: 18),
                _section('Address', Icons.location_on_outlined, [
                  _detail('Full address', user.address.fullAddress),
                  _detail('Latitude', user.address.geo.latitude),
                  _detail('Longitude', user.address.geo.longitude),
                ]),
                const SizedBox(height: 18),
                _section('Company', Icons.business_outlined, [
                  _detail('Company name', user.company.name),
                  _detail('Catchphrase', user.company.catchPhrase),
                  _detail('Business', user.company.business),
                ]),
                const SizedBox(height: 22),
                const Text(
                  'Sample data provided by JSONPlaceholder',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> details) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 21, color: AppTheme.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          ...details,
        ],
      ),
    ),
  );

  Widget _detail(String label, String value, {bool accent = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.muted),
        ),
        const SizedBox(height: 5),
        SelectableText(
          value,
          style: TextStyle(
            color: accent ? AppTheme.teal : AppTheme.ink,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
