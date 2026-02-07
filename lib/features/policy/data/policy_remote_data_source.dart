import 'package:http/http.dart' as http;
import 'policy_url_builder.dart';

class PolicyDataSource {
  const PolicyDataSource();

  String get policySeedUrl => _policyUrl;

  String get policyRouteUrl => PolicyLinkBuilder.composePolicyUrl(_policyUrl);

  Future<bool> checkPolicyAccess() async {
    try {
      final response = await http
          .get(
            Uri.parse(policyRouteUrl),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static const String _policyUrl =
      'https://clearbrookventures.online/privacy--policy?1=1';
}
