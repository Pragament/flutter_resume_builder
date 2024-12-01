import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/auth_provider.dart';
import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/models/git_repo_model.dart';
import 'package:resume_builder_app/providers/repo_provider.dart';
import 'package:resume_builder_app/views/repo_contents_screen.dart';

class RepoListScreen extends ConsumerStatefulWidget {
  const RepoListScreen({super.key});

  @override
  ConsumerState<RepoListScreen> createState() => _RepoListScreenState();
}

class _RepoListScreenState extends ConsumerState<RepoListScreen> {

  AuthStatus authStatus=AuthStatus.loading;

  @override
  void initState() {
    initialize();
    super.initState();
  }
  Future<void> initialize()async{
    final repo=ref.read(repoProvider);
    await repo.getToken();
    await repo.fetchRepositories(true);
  }

  @override
  Widget build(BuildContext context) {
    final repos=ref.watch(repoProvider);
    final auth=ref.watch(authProvider);
    authStatus=auth.authStatus;
    return Scaffold(
      appBar: AppBar(
        title: Text("Repo List"),
      ),
      body: !(authStatus==AuthStatus.authenticated)?Text("Login with GitHub first"):
      repos.isLoading
              ? Center(child: CircularProgressIndicator())
              : repos.hasError
                  ? Center(child: Text('Failed to load repositories'))
                  : ListView.builder(
                      itemCount: repos.repositories.length,
                      itemBuilder: (context, index) {
                        final repo = repos.repositories[index];
                        return Card(
                          elevation: 0,
                          child: ListTile(
                              title: Text(repo['name']),
                              subtitle:
                                  Text(repo['description'] ?? 'No description'),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RepoContentScreen(
                                              repo: GitRepo(
                                                  id: repo["id"],
                                                  nodeId: repo["node_id"],
                                                  name: repo["name"],
                                                  fullName: repo["full_name"],
                                                  owner: Owner(
                                                      login: repo["owner"]["login"],
                                                      id: repo["owner"]["id"],
                                                      avatarUrl: repo["owner"]["avatar_url"]),
                                                  private: repo["private"],
                                                  defaultBranch: repo['default_branch'],
                                                  permissions: Permissions(
                                                      admin: repo['permissions']['admin'],
                                                      push: repo['permissions']['push'],
                                                      pull: repo['permissions']['pull'])),
                                              ops: GitOperations(
                                                  token: repos.token),
                                          path: "/",
                                            )));
                              }),
                        );
                      },
                    ),
    );
  }
}