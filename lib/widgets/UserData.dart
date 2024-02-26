import 'package:flutter/material.dart';

class UserData extends InheritedWidget {
  final String userId;
  final List<Map<String, dynamic>> restaurants;
  final String profilePicUrl;

  UserData({
    required Widget child,
    required this.userId,
    required this.restaurants,
    required this.profilePicUrl,
  }) : super(child: child);

  static UserData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserData>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
