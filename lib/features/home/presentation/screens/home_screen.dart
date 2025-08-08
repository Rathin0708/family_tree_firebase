import 'package:family_tree_firebase/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Family Tree App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState.status == AuthStatus.authenticated && authState.user != null) {
                  final user = authState.user!;
                  return Column(
                    children: [
                      if (user.photoURL != null)
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user.photoURL!),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome, ${user.displayName ?? 'User'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (user.email != null)
                        Text(
                          user.email!,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                    ],
                  );
                }
                return const Text('User not logged in');
              },
            ),
          ],
        ),
      ),
    );
  }
}
