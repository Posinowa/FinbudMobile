import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void toLoginAndClearStack() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}