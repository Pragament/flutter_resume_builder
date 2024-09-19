import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/auth_provider.dart';


class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Resume',
              style: TextStyle(fontSize: 70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(18.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('Welcome', style: TextStyle(fontSize: 30)),
                    auth.authStatus == AuthStatus.loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async =>
                                await auth.signInWithGitHub(),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(Icons.login),
                                ),
                                Text('Login with GitHub'),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
