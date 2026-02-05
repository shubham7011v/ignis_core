import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import '../bloc/admin_bloc.dart';

class AdminLoginView extends StatelessWidget {
  final String? errorMessage;

  const AdminLoginView({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 64, color: Colors.redAccent),
            const SizedBox(height: 32),
            Text(
              errorMessage != null ? 'LOGIN FAILED' : 'UNAUTHORIZED ACCESS',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            Text(
              'User UID: ${FirebaseAuth.instance.currentUser?.uid ?? "Unknown"}',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              'API URL: ${AppConfig.instance.apiBaseUrl}',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 32),
            Text(
              errorMessage != null
                  ? 'Server rejected the administrative request.'
                  : 'This terminal is restricted to ${AppConfig.instance.isProduction ? "production" : "development"} administrators. Your UID must be registered in the mainframe via GitHub Secrets.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            if (errorMessage != null)
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AdminBloc>().add(AdminLogin());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RETRY INITIALIZATION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'RETREAT',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
