import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  static Map<String, dynamic>? decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final payload = _decodeBase64Url(parts[1]);
      final decoded = utf8.decode(payload);
      final json = jsonDecode(decoded);

      if (json is Map<String, dynamic>) {
        return json;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? expirationDate(String token) {
    final payload = decodePayload(token);
    final exp = payload?['exp'];

    if (exp is! num) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  static String? userId(String token) {
    return claimString(token, const ['sub', 'id', 'userId']);
  }

  static String? subject(String token) {
    return userId(token);
  }

  static String? email(String token) {
    return claimString(token, const [
      'email',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
    ]);
  }

  static String? role(String token) {
    return claimString(token, const [
      'role',
      'roles',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
    ]);
  }

  static String? claimString(String token, List<String> keys) {
    final payload = decodePayload(token);
    if (payload == null) {
      return null;
    }

    for (final key in keys) {
      final value = payload[key];
      if (value == null) {
        continue;
      }

      if (value is String && value.isNotEmpty) {
        return value;
      }

      if (value is num) {
        return value.toString();
      }

      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.isNotEmpty) {
          return first;
        }
        if (first is num) {
          return first.toString();
        }
      }
    }

    return null;
  }

  static bool isExpired(String token, {DateTime? referenceTime}) {
    final expiration = expirationDate(token);
    if (expiration == null) {
      return true;
    }

    final now = referenceTime ?? DateTime.now();
    return !expiration.isAfter(now);
  }

  static bool isUsable(String token, {DateTime? referenceTime}) {
    return !isExpired(token, referenceTime: referenceTime);
  }

  static List<int> _decodeBase64Url(String input) {
    final normalized = base64Url.normalize(input);
    return base64Url.decode(normalized);
  }
}
