import 'dart:async';

/// Utilitaire de debounce : déclenche `action` après [delay] sans nouvel
/// appel. Utilisé par les `SearchField` pour ne pas saturer l'API à
/// chaque frappe.
final class Debouncer {
  Debouncer({required this.delay});
  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
