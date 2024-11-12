class Job {
  final String jobId;
  final String title;
  final String companyId;
  final String location;
  final String employmentType;
  final Salary salary;
  final String description;
  final List<String> requirements;
  final String postedDate;
  final String expiryDate;
  final List<Company> companies;

  Job({
    required this.jobId,
    required this.title,
    required this.companyId,
    required this.location,
    required this.employmentType,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.postedDate,
    required this.expiryDate,
    required this.companies,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['jobId'],
      title: json['title'],
      companyId: json['companyId'],
      location: json['location'],
      employmentType: json['employmentType'],
      salary: Salary.fromJson(json['salary']),
      description: json['description'],
      requirements: List<String>.from(json['requirements']),
      postedDate: json['postedDate'],
      expiryDate: json['expiryDate'],
      companies: (json['companies'] as List)
          .map((companyJson) => Company.fromJson(companyJson))
          .toList(),
    );
  }
}

class Salary {
  final int min;
  final int max;
  final String currency;

  Salary({
    required this.min,
    required this.max,
    required this.currency,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      min: json['min'],
      max: json['max'],
      currency: json['currency'],
    );
  }
}

class Company {
  final String companyId;
  final String name;
  final String location;
  final String industry;
  final String website;
  final String logo;
  final List<Repository> repositories;

  Company({
    required this.companyId,
    required this.name,
    required this.location,
    required this.industry,
    required this.website,
    required this.logo,
    required this.repositories,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'],
      name: json['name'],
      location: json['location'],
      industry: json['industry'],
      website: json['website'],
      logo: json['Logo'],
      repositories: (json['repositories'] as List)
          .map((repoJson) => Repository.fromJson(repoJson))
          .toList(),
    );
  }
}

class Repository {
  final String owner;
  final String repo;

  Repository({
    required this.owner,
    required this.repo,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      owner: json['owner'],
      repo: json['repo'],
    );
  }
}