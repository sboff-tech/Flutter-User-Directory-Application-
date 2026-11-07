import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itt632_lab_2025197599/models/user.dart';
import 'package:itt632_lab_2025197599/screens/user_detail_screen.dart';
import 'package:itt632_lab_2025197599/screens/user_list_screen.dart';
import 'package:itt632_lab_2025197599/services/user_service.dart';
import 'package:itt632_lab_2025197599/theme/app_theme.dart';

import 'helpers/sample_users.dart';

class TestUserService extends UserService {
  TestUserService(this.load);
  final Future<List<User>> Function() load;
  int calls = 0;

  @override
  Future<List<User>> fetchUsers() {
    calls++;
    return load();
  }
}

void main() {
  Future<void> openDirectory(
    WidgetTester tester,
    TestUserService service,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: UserListScreen(service: service),
      ),
    );
  }

  testWidgets('shows a loading indicator while waiting for the server', (
    tester,
  ) async {
    final response = Completer<List<User>>();
    await openDirectory(tester, TestUserService(() => response.future));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading your directory'), findsOneWidget);
    response.complete(sampleUsers());
    await tester.pumpAndSettle();
    expect(find.text('Aisha Rahman'), findsOneWidget);
  });

  testWidgets('website extra field, search, clear and sort do not refetch', (
    tester,
  ) async {
    final service = TestUserService(
      () async => sampleUsers().reversed.toList(),
    );
    await openDirectory(tester, service);
    await tester.pumpAndSettle();
    expect(find.text('aisha.example.com'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'Rahman');
    await tester.pumpAndSettle();
    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('Daniel Tan'), findsNothing);
    await tester.enterText(find.byType(TextField), 'nobody matches');
    await tester.pumpAndSettle();
    expect(find.text('No matching contacts'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sort contacts'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<bool>, 'Name A–Z'),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Aisha Rahman')).dy,
      lessThan(tester.getTopLeft(find.text('Daniel Tan')).dy),
    );
    expect(service.calls, 1);
  });

  testWidgets('opens full details and returns to the directory', (
    tester,
  ) async {
    await openDirectory(tester, TestUserService(() async => sampleUsers()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aisha Rahman'));
    await tester.pumpAndSettle();
    expect(find.text('Contact details'), findsOneWidget);
    expect(find.text('012-3456789'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Full address'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Unit 8, Jalan Ilmu\nShah Alam, 40450'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Catchphrase'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ideas made simple'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('All contacts'), findsOneWidget);
  });

  testWidgets('Retry sends a new request and recovers after a failure', (
    tester,
  ) async {
    var offline = true;
    final service = TestUserService(() async {
      if (offline) {
        throw const UserApiException(
          FailureType.connection,
          'Check your internet connection.',
        );
      }
      return sampleUsers();
    });
    await openDirectory(tester, service);
    await tester.pumpAndSettle();
    expect(find.text('Check your internet connection.'), findsOneWidget);
    offline = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(service.calls, 2);
  });

  testWidgets('pull to refresh fetches again', (tester) async {
    final service = TestUserService(() async => sampleUsers());
    await openDirectory(tester, service);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(service.calls, 2);
  });

  testWidgets('empty API response has an empty state', (tester) async {
    await openDirectory(tester, TestUserService(() async => []));
    await tester.pumpAndSettle();
    expect(find.text('No contacts yet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(740, 360)]) {
    testWidgets('directory and details fit $size with large text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: UserListScreen(
            service: TestUserService(() async => sampleUsers()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: UserDetailScreen(user: sampleUsers().first),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
