import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';

class OAuthWebView extends StatefulWidget {
  final String url;
  final String callbackUrl;
  final String providerName;

  const OAuthWebView({
    super.key,
    required this.url,
    required this.callbackUrl,
    required this.providerName,
  });

  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView> {
  late final WebViewController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setUserAgent("Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1")
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _progress = 0.0;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _progress = 1.0;
            });

            // If we have reached the callback URL, extract response JSON
            if (url.startsWith(widget.callbackUrl)) {
              try {
                // Wait briefly to ensure page is loaded and DOM is fully populated
                await Future.delayed(const Duration(milliseconds: 300));
                
                final result = await _controller.runJavaScriptReturningResult(
                  "document.body.innerText"
                );
                
                String jsonStr = result.toString();
                
                // Clean up string wrapper if returned by native runJavaScriptReturningResult
                if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) {
                  jsonStr = jsonStr.substring(1, jsonStr.length - 1);
                  jsonStr = jsonStr
                      .replaceAll(r'\"', '"')
                      .replaceAll(r'\/', '/')
                      .replaceAll(r'\\', r'\');
                } else if (jsonStr.startsWith("'") && jsonStr.endsWith("'")) {
                  jsonStr = jsonStr.substring(1, jsonStr.length - 1);
                }
                
                if (mounted) {
                  Navigator.of(context).pop(jsonStr);
                }
              } catch (e) {
                debugPrint("Error extracting oauth callback json: $e");
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    const progressColor = AppColors.primaryPurple;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'Sign in with ${widget.providerName}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress < 1.0
              ? LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 2,
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
