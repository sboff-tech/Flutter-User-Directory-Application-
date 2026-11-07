import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:itt632_lab_2025197599/models/user.dart';
import 'package:itt632_lab_2025197599/services/user_service.dart';

import 'helpers/sample_users.dart';

void main() {
  const service = UserService();

  Future<List<User>> fetchWith(
    http.Client client, {
    UserService api = service,
  }) {
    return http.runWithClient(() => api.fetchUsers(), () => client);
  }

  Matcher failsWith(FailureType type) =>
      isA<UserApiException>().having((error) => error.type, 'type', type);

  test(
    'GET uses the required HTTPS endpoint and parses nested objects',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), UserService.endpoint);
        return http.Response(jsonEncode([sampleJson()]), 200);
      });
      final users = await fetchWith(client);
      expect(users.single.name, 'Aisha Rahman');
      expect(
        users.single.address.fullAddress,
        'Unit 8, Jalan Ilmu\nShah Alam, 40450',
      );
      expect(users.single.address.geo.longitude, '101.5183');
      expect(users.single.company.catchPhrase, 'Ideas made simple');
    },
  );

  for (final code in [404, 500, 503]) {
    test('status $code is handled before trying to decode the body', () async {
      final client = MockClient((_) async => http.Response('Not JSON', code));
      await expectLater(
        fetchWith(client),
        throwsA(failsWith(FailureType.server)),
      );
    });
  }

  for (final body in ['not json', '{}', '[42]', '[{"id":1}]']) {
    test(
      'invalid JSON or schema produces a readable data error: $body',
      () async {
        final client = MockClient((_) async => http.Response(body, 200));
        await expectLater(
          fetchWith(client),
          throwsA(failsWith(FailureType.invalidData)),
        );
      },
    );
  }

  test('network failure produces a connection error', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('Offline'),
    );
    await expectLater(
      fetchWith(client),
      throwsA(failsWith(FailureType.connection)),
    );
  });

  test('slow request times out', () async {
    final response = Completer<http.Response>();
    final client = MockClient((_) => response.future);
    await expectLater(
      fetchWith(
        client,
        api: const UserService(timeout: Duration(milliseconds: 10)),
      ),
      throwsA(failsWith(FailureType.timeout)),
    );
    response.complete(http.Response('[]', 200));
  });

  test('an empty server list stays empty', () async {
    final client = MockClient((_) async => http.Response('[]', 200));
    expect(await fetchWith(client), isEmpty);
  });
}
