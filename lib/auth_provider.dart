import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_builder_app/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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

  static Future<UserCredential?> signInWithGitLab() async {
    const String clientId = 'CLIENT ID';
    const String clientSecret = 'SECRET'; // If needed
    const String redirectUri = 'REDIRECT URL IN THE GITLAB';
    const String authorizationEndpoint = 'https://gitlab.com/oauth/authorize';
    const String tokenEndpoint = 'https://gitlab.com/oauth/token';
    const List<String> scopes = ['read_user','api'];

    try {
      final url =
        '$authorizationEndpoint?client_id=$clientId&redirect_uri=$redirectUri&response_type=code&scope=${scopes.join(' ')}';

      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'com.pragament.resumebuilder',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No code returned from GitLab');

      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
      );
      if (response.statusCode != 200) throw Exception('Failed to get access token');
      final Map<String, dynamic> tokenData = jsonDecode(response.body);
      final gitlabAccessToken = tokenData['access_token'];

      // Step 2: Exchange GitLab token for Firebase custom token
      final HttpsCallable callable = _functions.httpsCallable('createCustomTokenFromGitLab');
      final resultToken = await callable.call(<String, dynamic>{
        'gitlabAccessToken': gitlabAccessToken,
      });
      final String firebaseCustomToken = resultToken.data['token'];

      // Step 3: Sign in to Firebase with custom token
      final UserCredential userCredential = await _firebaseAuth.signInWithCustomToken(firebaseCustomToken);

      // Step 4: Store GitLab tokens for API access
      await _secureStorage.write(key: 'gitlab_access_token', value: gitlabAccessToken);

      return userCredential;
    } catch (e) {
      if (e is PlatformException && e.code == 'CANCELED') {
        // User canceled login, show a message or ignore
        print('User canceled GitLab login');
      } else {
        print('GitLab + Firebase sign-in error: $e');
      }
      return null;
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
