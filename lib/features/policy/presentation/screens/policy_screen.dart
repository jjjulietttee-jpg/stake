import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class PolicyScreen extends StatefulWidget {
  final String url;

  const PolicyScreen({super.key, required this.url});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (loadError) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    final content = WebViewWidget(controller: _controller);
    return Stack(
      children: [
        content,
        Positioned(
          top: 6,
          right: 6,
          child: _ExitButton(onPressed: () => context.go('/home')),
        ),
      ],
    );
  }
}

class _ExitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ExitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
