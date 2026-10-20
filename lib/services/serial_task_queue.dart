/// 저장 실패가 뒤 요청을 막거나 이전 값으로 덮어쓰지 않도록 순서대로 실행한다.
class SerialTaskQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() task) {
    final result = _tail.then((_) => task());
    // 호출자에게 오류를 돌려주되, 다음 작업은 실패 뒤에도 실행한다.
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
