import 'package:flutter/material.dart';
import 'package:code_hacker/services/audio_service.dart';

class AudioLifecycleManager extends StatefulWidget {
  final Widget child;

  const AudioLifecycleManager({super.key, required this.child});

  @override
  State<AudioLifecycleManager> createState() => _AudioLifecycleManagerState();
}

class _AudioLifecycleManagerState extends State<AudioLifecycleManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        AudioService().pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        AudioService().resumeBackgroundMusic();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 