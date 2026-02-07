class LinkHelper {
  static String sanitize(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.query.isEmpty) return raw;

    final cleaned = Map<String, String>.from(uri.queryParameters)
      ..removeWhere((k, v) => k == v);

    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
      queryParameters: cleaned.isEmpty ? null : cleaned,
      fragment: uri.fragment.isEmpty ? null : uri.fragment,
    ).toString();
  }

  static String encode(String url) => Uri.encodeComponent(url);

  static bool isValid(String url) => Uri.tryParse(url)?.hasScheme ?? false;
}
