import 'package:flutter/material.dart';

class UserData extends InheritedWidget {
  final String userId;
  final List<Map<String, dynamic>> restaurants;
  final String profilePicUrl;

  const UserData({super.key, 
    required super.child,
    required this.userId,
    required this.restaurants,
    required this.profilePicUrl,
  });

  static UserData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserData>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
