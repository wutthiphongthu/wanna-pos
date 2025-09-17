import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

// Use Flutter's built-in AppLifecycleState enum

abstract class AppLifecycleService {
  Stream<AppLifecycleState> get lifecycleStream;
  AppLifecycleState get currentState;
}

@Injectable(as: AppLifecycleService)
class AppLifecycleServiceImpl
    with WidgetsBindingObserver
    implements AppLifecycleService {
  final StreamController<AppLifecycleState> _lifecycleController =
      StreamController<AppLifecycleState>.broadcast();
  AppLifecycleState _currentState = AppLifecycleState.resumed;

  AppLifecycleServiceImpl() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Stream<AppLifecycleState> get lifecycleStream => _lifecycleController.stream;

  @override
  AppLifecycleState get currentState => _currentState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentState = state;
    _lifecycleController.add(state);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleController.close();
  }
}
