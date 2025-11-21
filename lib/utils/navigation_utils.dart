import 'package:flutter/material.dart';

import 'app_routes.dart';

class BottomNavNavigator {
  static const List<String> _tabRoutes = [
    AppRoutes.home,
    AppRoutes.tasks,
    AppRoutes.newPomori,
    AppRoutes.stats,
    AppRoutes.profile,
  ];

  static void goTo(BuildContext context, int index) {
    if (index < 0 || index >= _tabRoutes.length) {
      return;
    }

    final targetRoute = _tabRoutes[index];
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == targetRoute) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(targetRoute);
  }
}
