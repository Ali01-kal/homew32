import 'package:flutter/material.dart';
import 'package:learn_firebase_auth/auth_service.dart';
import 'package:learn_firebase_auth/screens/auth_screen.dart';
import 'package:learn_firebase_auth/screens/home_screen.dart';
import 'package:learn_firebase_auth/screens/verify_email_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return StreamBuilder(
      stream: auth.authStateChanges, 
      builder:(context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        final user = snapshot.data;

        if(user == null) return AuthScreen(auth: auth);

        if (!user.emailVerified) return VerifyEmailScreen(auth: auth);

        return HomeScreen(auth: auth);
      },);
  }
}