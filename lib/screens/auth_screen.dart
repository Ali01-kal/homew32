import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_firebase_auth/auth_service.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool isLogin = true;
  bool loading = false;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пайдаланушы табылмады';
      case 'wrong-password':
        return 'Қате пароль';
      case 'email-already-in-use':
        return 'Бұл email тіркелген';
      case 'invalid-email':
        return 'Email форматы қате';
      case 'weak-password':
        return 'Пароль әлсіз (кемі 6 символ)';
      case 'too-many-requests':
        return 'Тым көп әрекет. Кейінірек қайтала';
      default:
        return 'Қате: $code';
    }
  }

  Future<void> submit() async {
    final email = emailC.text.trim();
    final pass = passC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      snack('Email және пароль бос болмауы керек');
      return;
    }

    setState(() => loading = true);
    try {
      if (isLogin) {
        await widget.auth.login(email, pass);
      } else {
        await widget.auth.register(email, pass);
        snack('Тіркелді! Email-ды растау үшін хат жіберілді.');
      }
    } on FirebaseAuthException catch (e) {
      snack(_mapAuthError(e.code));
    } catch (_) {
      snack('Белгісіз қате');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> forgotPassword() async {
    final email = emailC.text.trim();
    if (email.isEmpty) {
      snack('Алдымен Email енгіз');
      return;
    }

    setState(() => loading = true);
    try {
      await widget.auth.sendPasswordReset(email);
      snack('Қалпына келтіру сілтемесі email-ға жіберілді');
    } on FirebaseAuthException catch (e) {
      snack(_mapAuthError(e.code));
    } catch (_) {
      snack('Белгісіз қате');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> googleSignIn() async {
    setState(() => loading = true);
    try {
      await widget.auth.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      snack(_mapAuthError(e.code));
    } catch (_) {
      snack('Google Sign-In қатесі (кейде SHA-1 керек болады)');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isLogin ? 'Login' : 'Register'),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: loading ? null : forgotPassword,
                child: const Text('Forgot password?'),
              ),
            ),

            const SizedBox(height: 6),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: loading ? null : googleSignIn,
                child: const Text('Sign in with Google'),
              ),
            ),

            const SizedBox(height: 6),

            TextButton(
              onPressed: loading ? null : () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? 'Аккаунт жоқ па? Register' : 'Аккаунт бар ма? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}