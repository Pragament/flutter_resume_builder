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
  const RepoListScreen({this.repoName, super.key});

  final String? repoName;

  @override
  ConsumerState<RepoListScreen> createState() => _RepoListScreenState();
}

class _RepoListScreenState extends ConsumerState<RepoListScreen> {
  AuthStatus authStatus = AuthStatus.loading;

  final TextEditingController _searchController = TextEditingController();
  final List<GitRepo> _filteredRepos = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final repo = ref.read(repoProvider);
    await repo.getToken();
    await repo.fetchRepositories(true);

    _filteredRepos.clear();
    _filteredRepos.addAll(repo.repositories);

    if(widget.repoName != null) _navigateToSpecificRepo();
  }

  void _navigateToSpecificRepo() {
    // Find the repository by name
    final targetRepo = _filteredRepos.firstWhere(
          (repo) => repo['name'] == widget.repoName,
      orElse: () => null,
    );

    if (targetRepo != null) {
      // Navigate to the specific repository
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RepoContentScreen(
                repo: GitRepo(
                  id: targetRepo["id"] as int? ?? 0,
                  nodeId: targetRepo["node_id"] as String? ?? "",
                  name: targetRepo["name"] as String? ?? "",
                  fullName: targetRepo["full_name"] as String? ?? "",
                  owner: Owner(
                    login: targetRepo["owner"]?["login"] as String? ?? "",
                    id: targetRepo["owner"]?["id"] as int? ?? 0,
                    avatarUrl: targetRepo["owner"]?["avatar_url"] as String? ?? "",
                  ),
                  private: targetRepo["private"] as bool? ?? false,
                  defaultBranch: targetRepo['default_branch'] as String? ?? "main",
                  permissions: Permissions(
                    admin: targetRepo['permissions']?['admin'] as bool? ?? false,
                    push: targetRepo['permissions']?['push'] as bool? ?? false,
                    pull: targetRepo['permissions']?['pull'] as bool? ?? false,
                  ),
                ),
                ops: GitOperations(token: ref.read(repoProvider).token),
                path: "/",
              ),
            ),
          );
        }
      });
    } else {
      // Repository not found, show error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Repository "${widget.repoName}" not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }

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
