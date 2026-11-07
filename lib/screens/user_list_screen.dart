import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_view.dart';
import '../widgets/user_card.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key, this.service = const UserService()});
  final UserService service;

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;
  final _searchController = TextEditingController();
  String _query = '';
  bool _sortByName = false;

  @override
  void initState() {
    super.initState();
    // Searching and rebuilding should not send another HTTP request.
    _usersFuture = widget.service.fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final request = widget.service.fetchUsers();
    setState(() {
      _usersFuture = request;
    });
    try {
      await request;
    } catch (_) {
      // FutureBuilder displays the error and Retry button.
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  List<User> _filterUsers(List<User> users) {
    final query = _query.trim().toLowerCase();
    final matches = users
        .where(
          (user) => [
            user.name,
            user.email,
            user.website,
            user.address.city,
            user.company.name,
          ].any((value) => value.toLowerCase().contains(query)),
        )
        .toList();
    if (_sortByName) {
      matches.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 18),
          child: Icon(Icons.people_alt_outlined, color: AppTheme.teal),
        ),
        title: const Text('User Directory'),
        actions: [
          IconButton(
            tooltip: 'About this directory',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'User Directory',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(
                Icons.people_alt_outlined,
                color: AppTheme.teal,
                size: 36,
              ),
              children: const [
                Text('Sample user data provided by JSONPlaceholder.'),
                SizedBox(height: 12),
                Text('Wan Syazrin\n2025197599 · ITT632'),
              ],
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const StatusView(
                    title: 'Loading your directory',
                    message: 'Getting the latest user details from the cloud.',
                    icon: Icons.cloud_download_outlined,
                    isLoading: true,
                  );
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  return StatusView(
                    title: 'Unable to load users',
                    message: error is UserApiException
                        ? error.message
                        : 'Something went wrong. Please try again.',
                    icon: Icons.cloud_off_rounded,
                    action: FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  );
                }

                final users = snapshot.data ?? [];
                final visibleUsers = _filterUsers(users);
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    key: const PageStorageKey('directory-list'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: visibleUsers.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildHeader(users);
                      if (index == 1) {
                        return _buildResultsHeading(users, visibleUsers);
                      }
                      final user = visibleUsers[index - 2];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UserCard(
                          user: user,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    UserDetailScreen(user: user),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<User> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.cloud_done_outlined,
                    color: Color(0xFF9DE2CF),
                    size: 17,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'JSONPlaceholder',
                      style: TextStyle(color: Color(0xFF9DE2CF), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'People, connected.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A little directory. Every detail in one place.',
                style: TextStyle(color: Color(0xFFC5D7D6), height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _summaryChip(Icons.people_outline, '${users.length} people'),
                  _summaryChip(
                    Icons.location_city_rounded,
                    '${users.map((user) => user.address.city).toSet().length} cities',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          key: const ValueKey('user-search'),
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: 'Search people, email or city',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );

  Widget _buildResultsHeading(List<User> users, List<User> visibleUsers) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _query.trim().isEmpty
                    ? 'All contacts'
                    : '${visibleUsers.length} ${visibleUsers.length == 1 ? 'result' : 'results'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            PopupMenuButton<bool>(
              tooltip: 'Sort contacts',
              initialValue: _sortByName,
              onSelected: (value) => setState(() => _sortByName = value),
              itemBuilder: (context) => [
                CheckedPopupMenuItem(
                  value: false,
                  checked: !_sortByName,
                  child: const Text('Original order'),
                ),
                CheckedPopupMenuItem(
                  value: true,
                  checked: _sortByName,
                  child: const Text('Name A–Z'),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      _sortByName ? 'A–Z' : 'Sort',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.sort_rounded,
                      size: 20,
                      color: AppTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (visibleUsers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Icon(
                  Icons.person_search_outlined,
                  size: 42,
                  color: AppTheme.muted,
                ),
                const SizedBox(height: 14),
                Text(
                  users.isEmpty ? 'No contacts yet' : 'No matching contacts',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  users.isEmpty
                      ? 'Pull down to check the directory again.'
                      : 'Try another name, email, website, company or city.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.muted, height: 1.5),
                ),
                if (_query.isNotEmpty)
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Clear search'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
