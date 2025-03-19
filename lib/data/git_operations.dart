import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class GitOperations {
  final String token;

  GitOperations({required this.token});

  Future<List<dynamic>> listRepositories(bool showPrivateRepos) async {
    final response = await http.get(
      Uri.parse(showPrivateRepos
          ? 'https://api.github.com/user/repos?visibility=all'
          : 'https://api.github.com/user/repos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load repositories');
    }
  }
  
    Future<List<String>> fetchGitHubImages(String owner,
        String repos,
        ) async {
    final url = Uri.parse(
        'https://api.github.com/repos/$owner/$repos/contents'); // Adjust folder path
  
    final response = await http.get(
      url,
      headers: {'Authorization': 'token $token'},
    );
  
    if (response.statusCode == 200) {
      final List<dynamic> files = jsonDecode(response.body);
      return files
          .where((file) =>
              file['name'].endsWith('.png') ||
              file['name'].endsWith('.jpg') ||
              file['name'].endsWith('.jpeg') ||
              file['name'].endsWith('.gif'))
          .map<String>((file) => file['download_url'])
          .toList();
    } else {
      throw Exception("Failed to load images from GitHub");
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

      final response = await http.put(
        Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': commitMessage,
          'content': base64Content,
        }),
      );
      if (response.statusCode != 201) {
        count += 1;
        throw Exception('Failed to add file to repository: ${response.body}');
      }
    }
    if (count > 0) {
      throw Exception('failed to add ${count} files');
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
