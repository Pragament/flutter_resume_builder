import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/shared_preferences.dart';
final repoProvider = ChangeNotifierProvider<RepoProvider>((ref) {
  return RepoProvider();
});

class RepoProvider with ChangeNotifier {
  List<dynamic> _repositories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _token="";

  List<dynamic> get repositories => _repositories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get token =>_token;

  Future<void> getToken()async{
    _token=await getAccessToken();
  }

  Future<void> fetchRepositories(bool showPrivateRepos) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _repositories=await GitOperations(token: _token).listRepositories(showPrivateRepos);
    } catch (e) {
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}
