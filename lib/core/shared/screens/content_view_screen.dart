import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class ContentViewScreen extends StatefulWidget {
  final String url;

  const ContentViewScreen({super.key, required this.url});

  @override
  State<ContentViewScreen> createState() => _ContentViewScreenState();
}

class _ContentViewScreenState extends State<ContentViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    _load();
  }

  Future<void> _load() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final view = WebViewWidget(controller: _controller);
    return Stack(
      children: [
        view,
        Positioned(
          top: 6,
          right: 6,
          child: _CloseAction(onPressed: () => context.go('/home')),
        ),
      ],
    );
  }
}

class _CloseAction extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseAction({required this.onPressed});

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
