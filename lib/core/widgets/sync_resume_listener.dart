import 'package:flutter/widgets.dart';

import '../di/injector.dart';
import '../sync/sync_manager.dart';

/// เรียก [SyncManager.syncAllOnAppResume] เมื่อแอปกลับมา foreground (หลัง login)
class SyncResumeListener extends StatefulWidget {
  const SyncResumeListener({super.key, required this.child});

  final Widget child;

  @override
  State<SyncResumeListener> createState() => _SyncResumeListenerState();
}

class _SyncResumeListenerState extends State<SyncResumeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIt<SyncManager>().syncAllOnAppResume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
