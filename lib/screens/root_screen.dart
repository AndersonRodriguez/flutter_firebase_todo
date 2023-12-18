import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_todo/model/auth_status.dart';
import 'package:flutter_firebase_todo/screens/home_screen.dart';
import 'package:flutter_firebase_todo/screens/login_screen.dart';
import 'package:flutter_firebase_todo/utils/loader_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AuthStatus _authStatus = AuthStatus.notDetermined;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? userId;

  @override
  void initState() {
    super.initState();

    getCurrentUser().then((user) {
      if (user != null) {
        userId = user.uid;
      }

      _authStatus =
          userId != null ? AuthStatus.loggedIn : AuthStatus.notLoggedIn;

      setState(() {});
    });
  }

  Future<User?> getCurrentUser() async => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notDetermined:
        return const LoaderScreen();
      case AuthStatus.notLoggedIn:
        return const LoginScreen();
      case AuthStatus.loggedIn:
        return HomeScreen(userId: userId!);
    }
  }
}
