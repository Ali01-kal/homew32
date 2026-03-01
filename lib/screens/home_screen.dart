import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_firebase_auth/auth_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nameC = TextEditingController();
  final photoC = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nameC.dispose();
    photoC.dispose();
    super.dispose();
  }

  void snack(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> saveProfile() async {
    setState(() => loading = true);
    try {
      await widget.auth.updateProfile(
        displayName: nameC.text,
        photoUrl: photoC.text,
      );
      setState(() {}); // UI refresh
      snack('Профиль сақталды');
    } catch (_) {
      snack('Профиль сақтау қатесі');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final photoUrl = user?.photoURL;
    final name = user?.displayName ?? 'No name';
    final email = user?.email ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => widget.auth.logOut(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 34,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person, size: 34)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(name, style: const TextStyle(fontSize: 18))),
            const SizedBox(height: 6),
            Center(child: Text(email)),
            const SizedBox(height: 6),
            Center(child: Text('Email verified: ${user?.emailVerified == true ? "Yes" : "No"}')),

            const Divider(height: 28),

            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'displayName (аты)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: photoC,
              decoration: const InputDecoration(
                labelText: 'photoURL (сурет сілтемесі)',
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}