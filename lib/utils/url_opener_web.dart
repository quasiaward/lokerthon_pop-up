import 'dart:html' as html;

/// 웹에서 외부 URL을 새 탭으로 연다.
void openExternalUrl(String url) {
  if (url.isEmpty) return;
  html.window.open(url, '_blank');
}
