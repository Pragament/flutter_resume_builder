/// resume_title : "Flutter Developer Resume"
/// name : "Rehaman Shaik"
/// email : "vdvddvkj"
/// created_at : "bsbjdbb"

class UserResume {
  UserResume({
      String? resumeTitle, 
      String? name, 
      String? email, 
      String? createdAt,}){
    _resumeTitle = resumeTitle;
    _name = name;
    _email = email;
    _createdAt = createdAt;
}

  UserResume.fromJson(dynamic json) {
    _resumeTitle = json['resume_title'];
    _name = json['name'];
    _email = json['email'];
    _createdAt = json['created_at'];
  }
  String? _resumeTitle;
  String? _name;
  String? _email;
  String? _createdAt;
UserResume copyWith({  String? resumeTitle,
  String? name,
  String? email,
  String? createdAt,
}) => UserResume(  resumeTitle: resumeTitle ?? _resumeTitle,
  name: name ?? _name,
  email: email ?? _email,
  createdAt: createdAt ?? _createdAt,
);
  String? get resumeTitle => _resumeTitle;
  String? get name => _name;
  String? get email => _email;
  String? get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['resume_title'] = _resumeTitle;
    map['name'] = _name;
    map['email'] = _email;
    map['created_at'] = _createdAt;
    return map;
  }

}