import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Tiene lo schermo acceso finché almeno una schermata lo chiede.
///
/// Conta le richieste: la Home e la modalità proiettore (aperta sopra la Home)
/// lo chiedono entrambe, e chiudere il proiettore non deve spegnere il
/// wakelock mentre la Home è ancora visibile.
class WakelockService {
  WakelockService._();

  static int _holders = 0;

  /// Sostituibile nei test per non toccare il canale di piattaforma.
  @visibleForTesting
  static Future<void> Function(bool enable) toggle = (enable) =>
      WakelockPlus.toggle(enable: enable);

  @visibleForTesting
  static int get holders => _holders;

  @visibleForTesting
  static void reset() => _holders = 0;

  static void acquire() {
    _holders++;
    if (_holders == 1) _apply(true);
  }

  static void release() {
    if (_holders == 0) return;
    _holders--;
    if (_holders == 0) _apply(false);
  }

  static void _apply(bool enable) {
    toggle(enable).catchError((Object e) {
      debugPrint('WakelockService.toggle($enable): $e');
    });
  }
}
