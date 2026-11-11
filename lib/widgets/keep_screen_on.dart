import 'package:flutter/widgets.dart';
import 'package:voto_tracker/services/wakelock_service.dart';

/// Tiene lo schermo acceso mentre [child] è nell'albero dei widget.
class KeepScreenOn extends StatefulWidget {
  const KeepScreenOn({super.key, required this.child});

  final Widget child;

  @override
  State<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends State<KeepScreenOn> {
  @override
  void initState() {
    super.initState();
    WakelockService.acquire();
  }

  @override
  void dispose() {
    WakelockService.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
