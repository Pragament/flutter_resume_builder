import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:resume_builder_app/views/jobs/models/jobissue_model.dart';

Future<List<GitHubIssue>> fetchUnassignedIssues(String owner, String repo) async {
  final url = Uri.parse('https://api.github.com/repos/$owner/$repo/issues?state=open&assignee=none');
  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/vnd.github+json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data
        .where((issue) => issue['pull_request'] == null) // Exclude pull requests
        .map((issue) => GitHubIssue.fromJson(issue))
        .toList();
  } else {
    throw Exception('Failed to load issues');
  }
}
// Creating a provider to fetch issues
final issuesProvider = FutureProvider.family<List<GitHubIssue>, Map<String, String>>((ref, params) {
  final owner = params['owner']!;
  final repo = params['repo']!;
  return fetchUnassignedIssues(owner, repo);
});