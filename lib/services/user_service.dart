import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

enum FailureType { connection, timeout, server, invalidData }

class UserApiException implements Exception {
  const UserApiException(this.type, this.message);

  final FailureType type;
  final String message;

  @override
  String toString() => message;
}

class UserService {
  const UserService({this.timeout = const Duration(seconds: 15)});

  static const endpoint = 'https://jsonplaceholder.typicode.com/users';
  final Duration timeout;

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(endpoint)).timeout(timeout);
      if (response.statusCode != 200) {
        throw UserApiException(
          FailureType.server,
          'The server returned status ${response.statusCode}. Please try again.',
        );
      }

      final data = jsonDecode(response.body);
      if (data is! List) {
        throw const FormatException('Expected a list of users.');
      }
      return data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid user record.');
        }
        return User.fromJson(item);
      }).toList();
    } on TimeoutException {
      throw const UserApiException(
        FailureType.timeout,
        'The request took too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const UserApiException(
        FailureType.connection,
        'Could not connect. Check your internet connection or turn off airplane mode, then retry.',
      );
    } on FormatException {
      throw const UserApiException(
        FailureType.invalidData,
        'The server sent data we could not read. Please try again later.',
      );
    } on TypeError {
      throw const UserApiException(
        FailureType.invalidData,
        'Some user details are missing or invalid. Please try again later.',
      );
    }
  }
}
