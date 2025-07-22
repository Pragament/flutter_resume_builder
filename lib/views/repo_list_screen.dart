import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/auth_provider.dart';
import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/models/git_repo_model.dart';
import 'package:resume_builder_app/providers/repo_provider.dart';
import 'package:resume_builder_app/views/repo_contents_screen.dart';

import 'widgets/bg_gradient_color.dart';

class RepoListScreen extends ConsumerStatefulWidget {
  const RepoListScreen({super.key});

  @override
  ConsumerState<RepoListScreen> createState() => _RepoListScreenState();
}

class _RepoListScreenState extends ConsumerState<RepoListScreen> {
  AuthStatus authStatus = AuthStatus.loading;

  final TextEditingController _searchController = TextEditingController();
  final List<GitRepo> _filteredRepos = [];

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    final repo = ref.read(repoProvider);
    await repo.getToken();
    await repo.fetchRepositories(true);

    _filteredRepos.clear();
    _filteredRepos.addAll(repo.repositories);
    setState(() {});
  }

  void _onSearchChanged(String value) {
    final repos = ref.read(repoProvider);
    final query = value.toLowerCase();

    setState(() {
      _filteredRepos.clear();
      _filteredRepos.addAll(
        repos.repositories.where(
          (repo) => repo.name.toLowerCase().contains(query),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final repos = ref.watch(repoProvider);
    final auth = ref.watch(authProvider);
    authStatus = auth.authStatus;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(1.sw, 60.h),
        child: BgGradientColor(
          child: AppBar(
            leading: BackButton(
              color: Colors.white,
              style: ButtonStyle(
                iconSize: WidgetStatePropertyAll(
                  20.sp,
                ),
              ),
            ),
            title: SearchBar(
              autoFocus: false,
              controller: _searchController,
              hintText: 'Search your repositories',
              onChanged: _onSearchChanged,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              trailing: [
                _searchController.text.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      )
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filteredRepos.clear();
                            _filteredRepos.addAll(repos.repositories);
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ],
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: !(authStatus == AuthStatus.authenticated)
          ? Text("Login with GitHub first")
          : repos.isLoading
              ? Center(child: CircularProgressIndicator())
              : repos.hasError
                  ? Center(child: Text('Failed to load repositories'))
                  : ListView.builder(
                      itemCount: _filteredRepos.length,
                      itemBuilder: (context, index) {
                        final repo = _filteredRepos[index];
                        return Card(
                          elevation: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(repo.name),
                                subtitle: Text(repo.description ?? 'No description'),
                                trailing: Checkbox(
                                  value: repo.isHighlighted,
                                  onChanged: (val) {
                                    ref.read(repoProvider).toggleHighlight(repo.id);
                                    setState(() {});
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RepoContentScreen(
                                        repo: repo,
                                        ops: GitOperations(token: repos.token),
                                        path: "/",
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (repo.isHighlighted)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: TextField(
                                    controller: TextEditingController(text: repo.customDescription ?? ""),
                                    decoration: InputDecoration(
                                      labelText: "Custom Description",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) {
                                      ref.read(repoProvider).setCustomDescription(repo.id, val);
                                    },
                                    maxLines: 2,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
