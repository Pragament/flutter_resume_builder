import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/models/git_repo_model.dart';
import 'package:resume_builder_app/shared_preferences.dart';

final repoProvider = ChangeNotifierProvider<RepoProvider>((ref) {
  return RepoProvider();
});

class RepoProvider with ChangeNotifier {
  List<GitRepo> _repositories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _token = "";

  List<GitRepo> get repositories => _repositories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get token => _token;

  Future<void> getToken() async {
    _token = await getAccessToken();
  }

  Future<void> fetchRepositories(bool showPrivateRepos) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final repoList = await GitOperations(token: _token).listRepositories(showPrivateRepos);
      _repositories = repoList.map<GitRepo>((repo) => GitRepo.fromMap(repo)).toList();
    } catch (e) {
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleHighlight(int repoId) {
    final index = _repositories.indexWhere((r) => r.id == repoId);
    if (index != -1) {
      _repositories[index].isHighlighted = !_repositories[index].isHighlighted;
      notifyListeners();
    }
  }

  void setCustomDescription(int repoId, String description) {
    final index = _repositories.indexWhere((r) => r.id == repoId);
    if (index != -1) {
      _repositories[index].customDescription = description;
      notifyListeners();
    }
  }
}
