import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../providers/settings_provider.dart';

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

  // Future<void> addFileToRepo(
  //     String owner,
  //     String repo,
  //     //String path,
  //     Map<String, File> files, //File file,
  //     String commitMessage) async {
  //   int count = 0;
  //   log(files.keys.first);
  //
  //   for (var entry in files.entries) {
  //     String path = entry.key;
  //     File file = entry.value;
  //     List<int> fileBytes = await file.readAsBytes();
  //     String base64Content = base64Encode(fileBytes);
  //
  //     // Check if the file already exists
  //     final checkResponse = await http.get(
  //       Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Accept': 'application/vnd.github.v3+json',
  //       },
  //     );
  //
  //     String? sha;
  //     if (checkResponse.statusCode == 200) {
  //       final data = json.decode(checkResponse.body);
  //       sha = data['sha'];
  //     }
  //
  //     // Create or update the file
  //     final response = await http.put(
  //       Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'message': commitMessage,
  //         'content': base64Content,
  //         if (sha != null) 'sha': sha,
  //       }),
  //     );
  //
  //     if (response.statusCode != 201 && response.statusCode != 200) {
  //       count += 1;
  //       throw Exception('Failed to add file to repository: ${response.body}');
  //     }
  //   }
  //
  //   if (count > 0) {
  //     throw Exception('Failed to add $count file(s)');
  //   }
  //   // List<int> fileBytes = await file.readAsBytes();
  //   // String base64Content = base64Encode(fileBytes);
  //
  //   // final response = await http.put(
  //   //   Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path'),
  //   //   headers: {
  //   //     'Authorization': 'Bearer $token',
  //   //     'Content-Type': 'application/json',
  //   //   },
  //   //   body: json.encode({
  //   //     'message': commitMessage,
  //   //     'content': base64Content,
  //   //   }),
  //   // );
  //   // if (response.statusCode != 201) {
  //   //   throw Exception('Failed to add file to repository: ${response.body}');
  //   // }
  // }

  Future<void> addFilesToRepo({
    required WidgetRef ref,
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
      // fallback to default branch
      final repoInfoResp = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo'),
        headers: headers,
      );

      if (repoInfoResp.statusCode != 200) {
        throw Exception('Failed to fetch repository info: ${repoInfoResp.body}');
      }

      final repoData = json.decode(repoInfoResp.body);
      branchToUse = repoData['default_branch'];
      log('Using default branch: $branchToUse');

      final defaultRefResp = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/git/ref/heads/$branchToUse'),
        headers: headers,
      );
      if (defaultRefResp.statusCode != 200) {
        throw Exception('Failed to fetch branch ref: ${defaultRefResp.body}');
      }
      final latestCommitSha = json.decode(defaultRefResp.body)['object']['sha'];

      await _createCommit(
        ref,
        owner,
        repo,
        branchToUse,
        latestCommitSha,
        files,
        commitMessage,
        headers,
      );
    } else {
      final latestCommitSha = json.decode(refResp.body)['object']['sha'];
      await _createCommit(
        ref,
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
      WidgetRef ref,
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

    final settings = ref.read(settingsProvider);

    for (var entry in files.entries) {
      String rawPath = entry.key;
      final path = rawPath.replaceFirst(RegExp(r'^/+'), ''); // Sanitize path
      final file = entry.value;

      // Check if it's an image
      final lowerName = file.path.toLowerCase();
      final isImage = lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png');

      File? finalFile;

      if (isImage) {
        finalFile = await compressImageFile(
          file: file,
          qualityPercent: settings.quality,
          maxFileSizeInKB: settings.maxFileSize,
        );

      } else {
        finalFile = file;
      }

      final bytes = await finalFile!.readAsBytes();
      if (bytes.isEmpty) {
        log("⚠️ Skipping empty file: $path");
        continue;
      }

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

    log('✅ Successfully committed ${files.length} file(s) to branch "$branch"');
  }

  Future<File?> compressImageFile({
    required File file,
    double? qualityPercent,
    double? maxFileSizeInKB,
    int minQuality = 10,
  }) async {
    final originalBytes = await file.readAsBytes();
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) throw Exception('Invalid image file');

    // Infer extension
    final ext = file.path.toLowerCase().split('.').last;
    int quality = (qualityPercent?.toInt() ?? 100).clamp(minQuality, 100);
    late Uint8List compressedBytes;

    while (true) {
      if (ext == 'png') {
        // PNG does not support quality, only compression level (0–9)
        compressedBytes = Uint8List.fromList(img.encodePng(decoded, level: 6));
      } else {
        // Default to JPG/JPEG
        compressedBytes = Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
      }

      final sizeKB = compressedBytes.lengthInBytes / 1024;

      final meetsSize = maxFileSizeInKB == null || sizeKB <= maxFileSizeInKB;
      final reachedMinQuality = quality <= minQuality;

      if (meetsSize || reachedMinQuality || ext == 'png') break;

      quality -= 5; // Reduce quality step by step
    }

    // Check again after loop
    final finalSizeKB = compressedBytes.lengthInBytes / 1024;
    if (maxFileSizeInKB != null && finalSizeKB > maxFileSizeInKB && ext != 'png') {
      log('⚠️ Could not compress under ${maxFileSizeInKB}KB. Final size: ${finalSizeKB.toStringAsFixed(1)}KB');
    }

    final dir = await getTemporaryDirectory();
    final tempPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final compressedFile = File(tempPath)..writeAsBytesSync(compressedBytes);

    return compressedFile;
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

  Future<Map<String, dynamic>> forkRepository({
    required String owner,
    required String repo,
    String? newName,
    String? newDescription,
    String? organization,
    bool? defaultBranchOnly,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repo/forks';

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {};
    if (newName != null) body['name'] = newName;
    if (organization != null) body['organization'] = organization;
    if (defaultBranchOnly != null) body['default_branch_only'] = defaultBranchOnly;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body.isNotEmpty ? json.encode(body) : null,
      );

      if (response.statusCode == 202) {
        final forkDetails = json.decode(response.body);

        // If newDescription is provided, update the forked repository
        if (newDescription != null) {
          await _updateRepositoryDescription(
            owner: forkDetails['owner']['login'],
            repo: forkDetails['name'],
            description: newDescription,
          );

          // Update the returned fork details with the new description
          forkDetails['description'] = newDescription;
        }

        return forkDetails;
      } else {
        throw Exception('Failed to fork repository: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateRepositoryDescription({
    required String owner,
    required String repo,
    required String description,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repo';

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json',
    };

    final body = {
      'description': description,
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update repository description: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update repository description: $e');
    }
  }

  Future<String> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return userData['login']; // GitHub username
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<Map<String, dynamic>> validateRepositoryName({
    required String owner,
    required String repoName,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repoName';

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Repository exists - name is not available
        return {
          'isAvailable': false,
          'message': 'Repository name already exists'
        };
      } else if (response.statusCode == 404) {
        // Repository doesn't exist - name is available
        return {
          'isAvailable': true,
          'message': 'Repository name is available'
        };
      } else {
        // Other errors (rate limiting, unauthorized, etc.)
        final errorData = json.decode(response.body);
        return {
          'isAvailable': false,
          'message': errorData['message'] ?? 'Failed to validate name. Please try again.'
        };
      }
    } catch (e) {
      return {
        'isAvailable': false,
        'message': 'Network error. Please check your connection.'
      };
    }
  }
}
