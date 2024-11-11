import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_builder_app/shared_preferences.dart';


enum AuthStatus { initial, authenticated, unauthenticated, loading }

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});



class AuthProvider extends ChangeNotifier {
  AuthStatus _authStatus = AuthStatus.initial;
  AuthStatus get authStatus => _authStatus;

  void checkAuthStatus() async {
    final auth = FirebaseAuth.instance;
    _authStatus = auth.currentUser != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<void> signInWithGitHub() async {
    try {
      _authStatus = AuthStatus.loading;
      notifyListeners();

      GithubAuthProvider githubAuthProvider = GithubAuthProvider();
      githubAuthProvider.addScope('repo');
      githubAuthProvider.addScope('public_repo');
      githubAuthProvider.setCustomParameters({'allow_signup': 'false'});

      final userCredential =
          await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);
      final token = userCredential.credential!.accessToken!;
      await setAccessToken(token);

      _authStatus = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      print(e.toString());
      _authStatus = AuthStatus.initial;

      notifyListeners();
    }
  }

  String? redirect({required GoRouterState state}) {
    final bool isAuthenticated = _authStatus == AuthStatus.authenticated;
    final currentPath = state.fullPath;

    if (!isAuthenticated && currentPath != '/') {
      return '/'; // Redirect to login if not logged in and not on login page
    }

    if (isAuthenticated && currentPath == '/') {
      return '/home'; // Redirect to home if logged in and on login page
    }


    return null; // No redirect needed
  }

  logOut() async {
    await FirebaseAuth.instance.signOut();

    _authStatus = AuthStatus.initial;

    notifyListeners();
  }
}
