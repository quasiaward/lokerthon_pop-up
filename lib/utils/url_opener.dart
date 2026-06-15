// 외부 링크를 새 탭에서 여는 헬퍼.
// 웹에서는 url_opener_web.dart(dart:html)를 사용하고,
// 그 외 플랫폼(테스트 VM 등)에서는 stub을 사용한다.
export 'url_opener_stub.dart'
    if (dart.library.html) 'url_opener_web.dart';
