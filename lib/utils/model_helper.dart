class ModelHelper {
  static String? safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }

  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static List<T> safeList<T>(
    dynamic value,
    T Function(dynamic json) mapper,
  ) {
    if (value is List) {
      return value.map(mapper).toList();
    }
    return <T>[];
  }
}
