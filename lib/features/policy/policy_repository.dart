import 'data/policy_remote_data_source.dart';

class PolicyStore {
  final PolicyDataSource _remote;

  const PolicyStore({PolicyDataSource? remote})
      : _remote = remote ?? const PolicyDataSource();

  Future<bool> checkPolicyAccess() {
    return _remote.checkPolicyAccess();
  }

  String get policyRouteUrl {
    return _remote.policyRouteUrl;
  }

  String get policySeedUrl {
    return _remote.policySeedUrl;
  }
}
