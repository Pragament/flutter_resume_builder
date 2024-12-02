class RepoContent {
  String name;
  String path;
  String sha;
  int size;
  String url;
  String htmlUrl;
  String gitUrl;
  String? downloadUrl;
  String type;
  Links links;

  RepoContent({
    required this.name,
    required this.path,
    required this.sha,
    required this.size,
    required this.url,
    required this.htmlUrl,
    required this.gitUrl,
    this.downloadUrl,
    required this.type,
    required this.links,
  });

  RepoContent copyWith({
    String? name,
    String? path,
    String? sha,
    int? size,
    String? url,
    String? htmlUrl,
    String? gitUrl,
    String? downloadUrl,
    String? type,
    Links? links,
  }) =>
      RepoContent(
        name: name ?? this.name,
        path: path ?? this.path,
        sha: sha ?? this.sha,
        size: size ?? this.size,
        url: url ?? this.url,
        htmlUrl: htmlUrl ?? this.htmlUrl,
        gitUrl: gitUrl ?? this.gitUrl,
        downloadUrl: downloadUrl ?? this.downloadUrl,
        type: type ?? this.type,
        links: links ?? this.links,
      );

  factory RepoContent.fromMap(Map<String, dynamic> json) => RepoContent(
    name: json["name"],
    path: json["path"],
    sha: json["sha"],
    size: json["size"],
    url: json["url"],
    htmlUrl: json["html_url"],
    gitUrl: json["git_url"],
    downloadUrl: json["download_url"],
    type: json["type"],
    links: Links.fromMap(json["_links"]),
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "path": path,
    "sha": sha,
    "size": size,
    "url": url,
    "html_url": htmlUrl,
    "git_url": gitUrl,
    "download_url": downloadUrl,
    "type": type,
    "_links": links.toMap(),
  };
}

class Links {
  String self;
  String git;
  String html;

  Links({
    required this.self,
    required this.git,
    required this.html,
  });

  Links copyWith({
    String? self,
    String? git,
    String? html,
  }) =>
      Links(
        self: self ?? this.self,
        git: git ?? this.git,
        html: html ?? this.html,
      );

  factory Links.fromMap(Map<String, dynamic> json) => Links(
    self: json["self"],
    git: json["git"],
    html: json["html"],
  );

  Map<String, dynamic> toMap() => {
    "self": self,
    "git": git,
    "html": html,
  };
}