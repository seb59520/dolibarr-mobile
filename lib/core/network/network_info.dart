import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service d'inspection de l'état réseau.
///
/// Sur web `connectivity_plus` se contente de détecter "online" via
/// `navigator.onLine`. Sur mobile il combine WiFi, mobile, ethernet, etc.
/// On expose une vue simplifiée binaire (online / offline) suffisante pour
/// piloter le SyncEngine et l'UI.
abstract interface class NetworkInfo {
  /// Snapshot synchrone du dernier état connu.
  bool get isOnline;

  /// Stream émettant à chaque changement d'état réseau.
  Stream<bool> get onStatusChange;

  /// Force une nouvelle lecture de l'état (utile au lancement de l'app
  /// avant d'attendre la première émission du listener).
  Future<bool> refresh();

  /// Libère les ressources (à appeler au dispose du provider).
  Future<void> dispose();
}

final class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity) {
    _subscription = _connectivity.onConnectivityChanged.listen(_onChange);
  }

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _lastKnown = false;

  @override
  bool get isOnline => _lastKnown;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> refresh() async {
    final results = await _connectivity.checkConnectivity();
    _onChange(results);
    return _lastKnown;
  }

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }

  void _onChange(List<ConnectivityResult> results) {
    final online = results.any(
      (r) =>
          r != ConnectivityResult.none && r != ConnectivityResult.bluetooth,
    );
    if (online != _lastKnown) {
      _lastKnown = online;
      _controller.add(online);
    } else if (!_controller.hasListener) {
      // Premier appel à refresh() : émet quand même pour amorcer.
      _lastKnown = online;
    }
  }
}
