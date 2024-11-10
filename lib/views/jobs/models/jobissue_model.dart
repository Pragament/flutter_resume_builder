// jobissue_model.dart
class GitHubIssue {
  final int id;
  final String title;
  final String url;
  final String comments_url;
  final String repository_url;
  final String body;



  GitHubIssue({
    required this.id,
    required this.title,
    required this.url,
    required this.comments_url,
    required this.repository_url,
    required this.body,

  });

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    return GitHubIssue(
      id: json['id'],
      title: json['title'],
      url: json['html_url'],
      comments_url: json['comments_url'],
      repository_url: json['repository_url'],
        body: json['body'],
    );
  }
}
