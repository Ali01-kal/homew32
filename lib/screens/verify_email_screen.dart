import 'package:flutter/material.dart';
import 'package:learn_firebase_auth/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool loading = false;

  void snack(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> resend() async {
    setState(() => loading = true);
    try {
      await widget.auth.resendEmailVerification();
      snack('Растау хаты қайта жіберілді');
    } catch (_) {
      snack('Қате');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> refresh() async {
    setState(() => loading = true);
    try {
      await widget.auth.reloadUser();
      snack('Жаңартылды. Егер email растаған болсаң — Home ашылады.');
      // AppRoot StreamBuilder user.emailVerified жаңарғанын көріп Home-қа өткізеді
    } catch (_) {
      snack('Қате');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.auth.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Email-ды растау керек.\nПоштаңа келген хаттағы сілтемені бас.\n\nEmail: $email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : resend,
                child: const Text('Resend verification email'),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: loading ? null : refresh,
                child: const Text('I verified → Refresh'),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: loading ? null : () => widget.auth.logOut(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}