import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class GitOperations {
  final String token;

  GitOperations({required this.token});

  Future<List<dynamic>> listRepositories(bool showPrivateRepos) async {
    const int perPage = 100;
    int page = 1;
    List<dynamic> allRepos = [];

    while (true) {
      final response = await http.get(
        Uri.parse(showPrivateRepos
            ? 'https://api.github.com/user/repos?visibility=all&per_page=$perPage&page=$page'
            : 'https://api.github.com/user/repos?per_page=$perPage&page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load repositories');
      }

      final List<dynamic> repos = json.decode(response.body);
      allRepos.addAll(repos);

      // If fewer results than perPage, we're done
      if (repos.length < perPage) {
        break;
      }

      page++;
    }
    return allRepos;
  }

  Future<List<String>> fetchGitHubImages(
    String owner,
    String repos,
  ) async {
    final url = Uri.parse(
        'https://api.github.com/repos/$owner/$repos/contents'); // Adjust folder path

    //log("fetchGitHubImages url ${url.toString()}");
    final response = await http.get(
      url,
      headers: {'Authorization': 'token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> files = jsonDecode(response.body);
      //log("fetchGitHubImages ${files.toString()}");
      return files
          .where((file) =>
              file['name'].endsWith('.png') ||
              file['name'].endsWith('.jpg') ||
              file['name'].endsWith('.jpeg') ||
              file['name'].endsWith('.gif'))
          .map<String>((file) => file['download_url'])
          .toList();
    } else {
      throw Exception("Failed to load images from GitHub: ${response.body}");
    }
  }

  Future<void> createRepository(String repoName, bool isPrivate) async {
    final response = await http.post(
      Uri.parse('https://api.github.com/user/repos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': repoName,
        'private': isPrivate,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create repository');
    }
  }

  Future<void> addFileToRepo(
      String owner,
      String repo,
      //String path,
      Map<String, File> files, //File file,
      String commitMessage) async {
    int count = 0;

    for (var entry in files.entries) {
      String path = entry.key;
      File file = entry.value;
      List<int> fileBytes = await file.readAsBytes();
      String base64Content = base64Encode(fileBytes);

      // Check if the file already exists
      final checkResponse = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      String? sha;
      if (checkResponse.statusCode == 200) {
        final data = json.decode(checkResponse.body);
        sha = data['sha'];
      }

      // Create or update the file
      final response = await http.put(
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': commitMessage,
          'content': base64Content,
          if (sha != null) 'sha': sha,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        count += 1;
        throw Exception('Failed to add file to repository: ${response.body}');
      }
    }

    if (count > 0) {
      throw Exception('Failed to add $count file(s)');
    }
    // List<int> fileBytes = await file.readAsBytes();
    // String base64Content = base64Encode(fileBytes);

    // final response = await http.put(
    //   Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: json.encode({
    //     'message': commitMessage,
    //     'content': base64Content,
    //   }),
    // );
    // if (response.statusCode != 201) {
    //   throw Exception('Failed to add file to repository: ${response.body}');
    // }
  }

  Future<void> commitMultipleFiles({
    required String owner,
    required String repo,
    required Map<String, File> files,
    required String commitMessage,
    String branch = 'main',
  }) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'Content-Type': 'application/json',
    };

    // Step 1: Try to get the specified branch ref
    String branchToUse = branch;
    final branchRefUrl = 'https://api.github.com/repos/$owner/$repo/git/ref/heads/$branch';
    final refResp = await http.get(Uri.parse(branchRefUrl), headers: headers);

    if (refResp.statusCode != 200) {
      // If the specified branch doesn't exist, fetch default branch
      print('⚠️ Branch "$branch" not found. Falling back to default branch...');
      final repoInfoResp = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo'),
        headers: headers,
      );

      if (repoInfoResp.statusCode != 200) {
        throw Exception('Failed to fetch repository info: ${repoInfoResp.body}');
      }

      final repoData = json.decode(repoInfoResp.body);
      branchToUse = repoData['default_branch'];
      print('✅ Using default branch: $branchToUse');

      // Try getting ref for default branch
      final defaultRefResp = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/git/ref/heads/$branchToUse'),
        headers: headers,
      );
      if (defaultRefResp.statusCode != 200) {
        throw Exception('Failed to fetch branch ref for default branch: ${defaultRefResp.body}');
      }
      final latestCommitSha = json.decode(defaultRefResp.body)['object']['sha'];
      await _createCommit(
        owner,
        repo,
        branchToUse,
        latestCommitSha,
        files,
        commitMessage,
        headers,
      );
    } else {
      // If original branch exists, proceed
      final latestCommitSha = json.decode(refResp.body)['object']['sha'];
      await _createCommit(
        owner,
        repo,
        branchToUse,
        latestCommitSha,
        files,
        commitMessage,
        headers,
      );
    }
  }

  Future<void> _createCommit(
      String owner,
      String repo,
      String branch,
      String latestCommitSha,
      Map<String, File> files,
      String commitMessage,
      Map<String, String> headers,
      ) async {
    final commitResp = await http.get(
      Uri.parse('https://api.github.com/repos/$owner/$repo/git/commits/$latestCommitSha'),
      headers: headers,
    );
    if (commitResp.statusCode != 200) {
      throw Exception('Failed to fetch commit: ${commitResp.body}');
    }
    final baseTreeSha = json.decode(commitResp.body)['tree']['sha'];

    List<Map<String, dynamic>> treeEntries = [];

    for (var entry in files.entries) {
      final path = entry.key;
      final file = entry.value;
      final bytes = await file.readAsBytes();
      final isBinary = _isBinary(bytes);
      final encoded = isBinary ? base64Encode(bytes) : utf8.decode(bytes);
      final encoding = isBinary ? 'base64' : 'utf-8';

      final blobResp = await http.post(
        Uri.parse('https://api.github.com/repos/$owner/$repo/git/blobs'),
        headers: headers,
        body: json.encode({
          'content': encoded,
          'encoding': encoding,
        }),
      );

      if (blobResp.statusCode != 201) {
        throw Exception('Failed to create blob for $path: ${blobResp.body}');
      }

      final blobSha = json.decode(blobResp.body)['sha'];
      treeEntries.add({
        'path': path,
        'mode': '100644',
        'type': 'blob',
        'sha': blobSha,
      });
    }

    final treeResp = await http.post(
      Uri.parse('https://api.github.com/repos/$owner/$repo/git/trees'),
      headers: headers,
      body: json.encode({
        'base_tree': baseTreeSha,
        'tree': treeEntries,
      }),
    );
    if (treeResp.statusCode != 201) {
      throw Exception('Failed to create tree: ${treeResp.body}');
    }

    final newTreeSha = json.decode(treeResp.body)['sha'];

    final commitResp2 = await http.post(
      Uri.parse('https://api.github.com/repos/$owner/$repo/git/commits'),
      headers: headers,
      body: json.encode({
        'message': commitMessage,
        'tree': newTreeSha,
        'parents': [latestCommitSha],
      }),
    );
    if (commitResp2.statusCode != 201) {
      throw Exception('Failed to create commit: ${commitResp2.body}');
    }

    final newCommitSha = json.decode(commitResp2.body)['sha'];

    final updateResp = await http.patch(
      Uri.parse('https://api.github.com/repos/$owner/$repo/git/refs/heads/$branch'),
      headers: headers,
      body: json.encode({'sha': newCommitSha}),
    );
    if (updateResp.statusCode != 200) {
      throw Exception('Failed to update branch ref: ${updateResp.body}');
    }

    log('Successfully committed ${files.length} file(s) to branch "$branch"');
  }


  bool _isBinary(List<int> bytes) {
    const textBytes = [9, 10, 13];
    for (var b in bytes) {
      if (b < 32 && !textBytes.contains(b)) return true;
    }
    return false;
  }

  Future<dynamic> getRepoContents(
      String owner, String repo, String path) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get repository contents');
    }
  }

  Future<void> updateFileInRepo(String owner, String repo, String path,
      String newContent, String commitMessage) async {
    final apiUrl = 'https://api.github.com/repos/$owner/$repo/contents/$path';

    // Step 1: Get the current file contents
    final getResponse = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (getResponse.statusCode != 200) {
      throw Exception('Failed to get file: ${getResponse.body}');
    }

    final fileInfo = json.decode(getResponse.body);
    final String sha = fileInfo['sha'];

    // Step 2 & 3: Update content and create a commit
    final updateResponse = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'message': commitMessage,
        'content': base64Encode(utf8.encode(newContent)),
        'sha': sha,
      }),
    );

    if (updateResponse.statusCode != 200) {
      throw Exception('Failed to update file: ${updateResponse.body}');
    }

    log('File updated successfully');
  }

  Future<List<dynamic>> getRepoCollaborators(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$owner/$repo/collaborators'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to fetch collaborators for repository $repo: ${response.body}');
    }
  }

  // Fetch collaborators for multiple repositories
  Future<Map<String, List<dynamic>>> getCollaboratorsForSelectedRepos(
      List<Map<String, String>> selectedRepos) async {
    final collaboratorsMap = <String, List<dynamic>>{};

    for (final repoInfo in selectedRepos) {
      final owner = repoInfo['owner']!;
      final repo = repoInfo['repo']!;

      try {
        final collaborators = await getRepoCollaborators(owner, repo);
        collaboratorsMap[repo] = collaborators;
      } catch (e) {
        log('Error fetching collaborators for $repo: $e');
      }
    }

    return collaboratorsMap;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getCommitsForSelectedRepos({
    required List<Map<String, String>> selectedRepos,
    required List<String> selectedCollaborators,
    required DateTime since,
    required DateTime until,
  }) async {
    final commitsMap = <String, List<Map<String, dynamic>>>{};

    for (final repoInfo in selectedRepos) {
      final owner = repoInfo['owner']!;
      final repo = repoInfo['repo']!;

      for (final collaborator in selectedCollaborators) {
        final queryParameters = {
          'author': collaborator,
          'since': since.toUtc().toIso8601String(),
          'until': until.toUtc().toIso8601String(),
        };

        final uri = Uri.https(
          'api.github.com',
          '/repos/$owner/$repo/commits',
          queryParameters,
        );

        try {
          final response = await http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> commits = json.decode(response.body);
            log("raw${commits[0]}");
            final parsedCommits = commits.map<Map<String, dynamic>>((commit) {
              return {
                'sha': commit['sha'],
                'message': commit['commit']['message'],
                'author': commit['commit']['author']['name'],
                'date': commit['commit']['author']['date'],
                'url': commit['html_url'],
              };
            }).toList();

            commitsMap[repo] = [...(commitsMap[repo] ?? []), ...parsedCommits];
          } else {
            throw Exception('Failed to fetch commits for repository $repo');
          }
        } catch (e) {
          log('Error fetching commits for $repo by $collaborator: $e');
        }
      }
    }
    //printInDebug("commit map$commitsMap");
    return commitsMap;
  }

  Future<Map<String, dynamic>> getCommitDetails({
    required String owner,
    required String repo,
    required String ref,
  }) async {
    final url = 'https://api.github.com/repos/Harsh-Vipin/$repo/commits/$ref';

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final commitDetails = json.decode(response.body);

        return commitDetails;
      } else {
        throw Exception('Failed to fetch commit details: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
