import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tbcheck_app/core/utils/jwt_utils.dart';

String buildToken(Map<String, dynamic> payload) {
  String encodeSegment(String value) {
    return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  }

  final header = encodeSegment('{"alg":"none","typ":"JWT"}');
  final body = encodeSegment(jsonEncode(payload));
  return '$header.$body.signature';
}

void main() {
  test('decodePayload returns decoded payload map', () {
    final token = buildToken({
      'exp': 2000000000,
      'sub': '123',
      'email': 'user@example.com',
      'role': 'user',
    });

    final payload = JwtUtils.decodePayload(token);

    expect(payload, isNotNull);
    expect(payload?['exp'], 2000000000);
    expect(payload?['sub'], '123');
    expect(payload?['email'], 'user@example.com');
    expect(payload?['role'], 'user');
  });

  test('claim helpers read standard jwt fields', () {
    final token = buildToken({
      'sub': '123',
      'email': 'user@example.com',
      'role': 'admin',
    });

    expect(JwtUtils.userId(token), '123');
    expect(JwtUtils.subject(token), '123');
    expect(JwtUtils.email(token), 'user@example.com');
    expect(JwtUtils.role(token), 'admin');
  });

  test('isExpired returns true for expired token', () {
    final token = buildToken({'exp': 1});

    expect(
      JwtUtils.isExpired(
        token,
        referenceTime: DateTime.fromMillisecondsSinceEpoch(2000),
      ),
      isTrue,
    );
  });

  test('isUsable returns false for malformed token', () {
    expect(JwtUtils.isUsable('not-a-jwt'), isFalse);
  });
}
