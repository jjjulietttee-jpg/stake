import 'dart:async';
import 'policy_repository.dart';

abstract class PolicyFlowState {
  const PolicyFlowState();
}

class PolicyFlowInProgress extends PolicyFlowState {
  const PolicyFlowInProgress();
}

class PolicyFlowReady extends PolicyFlowState {
  final bool policyAllowed;
  final String policyUrl;

  const PolicyFlowReady({required this.policyAllowed, required this.policyUrl});
}

class PolicyFlowBloc {
  final PolicyStore _repository;
  final StreamController<PolicyFlowState> _controller =
      StreamController<PolicyFlowState>.broadcast();
  bool _policyReady = false;
  bool? _policyAllowed;
  bool _policyEmitted = false;

  PolicyFlowBloc({PolicyStore? repository})
      : _repository = repository ?? const PolicyStore();

  Stream<PolicyFlowState> get stream => _controller.stream;

  void beginPolicyFlow() {
    _controller.add(const PolicyFlowInProgress());
    _checkPolicyAccess();
  }

  void markPolicyReady() {
    _policyReady = true;
    _emitPolicyReady();
  }

  void _checkPolicyAccess() async {
    _policyAllowed = await _repository.checkPolicyAccess();
    _emitPolicyReady();
  }

  void _emitPolicyReady() {
    if (_policyEmitted || !_policyReady || _policyAllowed == null) return;
    _policyEmitted = true;
    _controller.add(
      PolicyFlowReady(
        policyAllowed: _policyAllowed ?? false,
        policyUrl: _repository.policyRouteUrl,
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
