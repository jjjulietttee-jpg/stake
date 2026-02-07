import 'package:http/http.dart' as http;
import '../utils/link_helper.dart';

class RemoteConfigService {
  RemoteConfigService();

  static const String _endpoint =
      'https://clearbrookventures.online/privacy--policy?1=1';

  bool _available = false;

  bool get isAvailable => _available;

  String get rawEndpoint => _endpoint;

  String get resolvedEndpoint => LinkHelper.sanitize(_endpoint);

  Future<bool> fetchAvailability() async {
    try {
      final response = await http
          .get(
            Uri.parse(resolvedEndpoint),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      _available = response.statusCode == 200;
      return _available;
    } catch (_) {
      _available = false;
      return false;
    }
  }
}
