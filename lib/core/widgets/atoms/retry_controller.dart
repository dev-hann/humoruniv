import 'dart:async';

class RetryController {
  RetryController({
    this.maxAttempts = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.onRetry,
  });

  final int maxAttempts;
  final Duration retryDelay;
  final void Function(int attempt)? onRetry;

  int _attempt = 0;
  bool _failed = false;
  String _url = '';
  Timer? _timer;

  int get attempt => _attempt;
  bool get hasError => _failed;
  bool get canAutoRetry => _failed && _attempt < maxAttempts - 1;
  bool get isExhausted => _failed && _attempt >= maxAttempts - 1;

  void recordFailure() {
    _failed = true;
    if (_attempt >= maxAttempts - 1) return;
    final next = _attempt + 1;
    _timer?.cancel();
    _timer = Timer(retryDelay, () {
      _timer = null;
      _attempt = next;
      _failed = false;
      onRetry?.call(_attempt);
    });
  }

  void manualRetry() {
    _timer?.cancel();
    _timer = null;
    _attempt = 0;
    _failed = false;
  }

  void resetForUrl(String url) {
    if (url == _url) return;
    _url = url;
    _timer?.cancel();
    _timer = null;
    _attempt = 0;
    _failed = false;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
