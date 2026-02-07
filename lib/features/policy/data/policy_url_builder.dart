class PolicyLinkBuilder {
  static String composePolicyUrl(String url) {
    final parsed = Uri.tryParse(url);
    if (parsed == null) return url;
    if (parsed.query.isEmpty) return url;

    final params = PolicyQueryHelper.normalize(parsed.queryParameters);

    return Uri(
      scheme: parsed.scheme,
      userInfo: parsed.userInfo,
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : null,
      path: parsed.path,
      queryParameters: params.isEmpty ? null : params,
      fragment: parsed.fragment,
    ).toString();
  }
}

class PolicyQueryHelper {
  static Map<String, String> normalize(Map<String, String> input) {
    final params = Map<String, String>.from(input);
    if (params['1'] == '1') {
      params.remove('1');
    }
    return params;
  }
}
