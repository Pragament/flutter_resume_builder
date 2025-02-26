import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_builder_app/shared_preferences.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  continueWithoutLogin,
  loading
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  AuthStatus _authStatus = AuthStatus.initial;
  AuthStatus get authStatus => _authStatus;

  void checkAuthStatus() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      _authStatus = AuthStatus.authenticated;
    } else if (_authStatus != AuthStatus.continueWithoutLogin &&
        _authStatus != AuthStatus.loading) {
      _authStatus = AuthStatus.unauthenticated;
    }
  }

  void continueWithoutLogin(BuildContext context) {
    _authStatus = AuthStatus.continueWithoutLogin;
    notifyListeners();
  }

  Future<void> signInWithGitHub() async {
    try {
      _authStatus = AuthStatus.loading;
      notifyListeners();
      print("listening");

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
    final bool isUnauthenticated = _authStatus == AuthStatus.unauthenticated;
    final currentPath = state.fullPath;

    if (isUnauthenticated && currentPath != '/') {
      return '/'; // Redirect to login if not logged in and not on login page
    }
    if (isAuthenticated && currentPath == '/') {
      return '/home'; // Redirect to home if logged in and on login page
    }
    if (_authStatus == AuthStatus.continueWithoutLogin && currentPath == '/') {
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
