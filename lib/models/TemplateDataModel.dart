import 'dart:ui';

import 'package:flutter_resume_template/flutter_resume_template.dart';

class TemplateDataModel {
  TemplateDataModel({
    String fullName='',
    String? currentPosition,
    String? street,
    String? address,
    String? country,
    String? email,
    String? phoneNumber,
    String? bio,
    List<ExperienceData> experience=const [],
    List<Education> educationDetails=const [],
    List<Language> languages=const[],
    List<String> hobbies=const[],
    String?  image,
    String? backgroundImage,
  }) {
    _fullName = fullName;
    _currentPosition = currentPosition;
    _street = street;
    _address = address;
    _country = country;
    _email = email;
    _phoneNumber = phoneNumber;
    _bio = bio;
    _experience = experience;
    _educationDetails = educationDetails;
    _languages = languages;
    _hobbies = hobbies;
    _image = image;
    _backgroundImage = backgroundImage;
  }

  String _fullName='';
  String? _currentPosition;
  String? _street;
  String? _address;
  String? _country;
  String? _email;
  String? _phoneNumber;
  String? _bio;
  List<ExperienceData> _experience=[];
  List<Education> _educationDetails=[];
  List<Language> _languages=[];
  List<String> _hobbies=[];
  String? _image;
  String? _backgroundImage;

  TemplateDataModel copyWith({String? fullName,
    String? currentPosition,
    String? street,
    String? address,
    String? country,
    String? email,
    String? phoneNumber,
    String? bio,
    List<ExperienceData>? experience,
    List<Education>? educationDetails,
    List<Language>? languages,
    List<String>? hobbies,
    String? image,
    String? backgroundImage,
  }) => TemplateDataModel(  fullName: fullName ?? _fullName,
    currentPosition: currentPosition ?? _currentPosition,
    street: street ?? _street,
    address: address ?? _address,
    country: country ?? _country,
    email: email ?? _email,
    phoneNumber: phoneNumber ?? _phoneNumber,
    bio: bio ?? _bio,
    experience: experience ?? _experience,
    educationDetails: educationDetails ?? _educationDetails,
    languages: languages ?? _languages,
    hobbies: hobbies ?? _hobbies,
    image: image ?? _image,
    backgroundImage: backgroundImage ?? _backgroundImage,
  );

  String get fullName => _fullName;
  String? get currentPosition => _currentPosition;
  String? get street => _street;
  String? get address => _address;
  String? get country => _country;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get bio => _bio;
  List<ExperienceData> get experience => _experience;
  List<Education> get educationDetails => _educationDetails;
  List<Language> get languages => _languages;
  List<String> get hobbies => _hobbies;
  String? get image => _image;
  String? get backgroundImage => _backgroundImage;

  static TemplateDataModel fromJson(Map<String, dynamic> json) {
    return TemplateDataModel(
      fullName: json['fullName'] ?? '',
      currentPosition: json['currentPosition'],
      street: json['street'],
      address: json['address'],
      country: json['country'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
      experience: (json['experience'] as List<dynamic>?)
          ?.map((item) => experienceDataFromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      educationDetails: (json['educationDetails'] as List<dynamic>?)
          ?.map((item) => educationFromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      languages: (json['languages'] as List<dynamic>?)
          ?.map((item) => languageFromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      hobbies: (json['hobbies'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ?? [],
      image: json['image'],
      backgroundImage: json['backgroundImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': _fullName,
      'currentPosition': _currentPosition,
      'street': _street,
      'address': _address,
      'country': _country,
      'email': _email,
      'phoneNumber': _phoneNumber,
      'bio': _bio,
      'experience': _experience.map((item) => experienceToJson(item)).toList(),
      'educationDetails': _educationDetails.map((item) => educationToJson(item)).toList(),
      'languages': _languages.map((item) => languagesToJson(item)).toList(),
      'hobbies': _hobbies,
      'image': _image,
      'backgroundImage': _backgroundImage,
    };
  }
  
   Map<String,dynamic> experienceToJson(ExperienceData experience){
    Map<String,dynamic> data={
      'experienceTitle':experience.experienceTitle,
      'experiencePlace':experience.experiencePlace,
      'experiencePeriod':experience.experiencePeriod,
      'experienceLocation':experience.experienceLocation,
      'experienceDescription':experience.experienceDescription,
    };
    return data;
  }

  static ExperienceData experienceDataFromJson(Map<String, dynamic> json) {
    return ExperienceData(
      experienceTitle: json['experienceTitle'] ?? '',
      experiencePlace: json['experiencePlace'] ?? '',
      experiencePeriod: json['experiencePeriod'] ?? '',
      experienceLocation: json['experienceLocation'] ?? '',
      experienceDescription: json['experienceDescription'] ?? '',
    );
  }

  Map<String,dynamic> educationToJson(Education educationDetails){
    Map<String,dynamic> data={
      'schoolName':educationDetails.schoolName ,
      'schoolLevel':educationDetails.schoolLevel,
    };
    return data;
  }


  static Education educationFromJson(Map<String, dynamic> json) {
    return Education(
      json['schoolName'] ?? '',
      json['schoolLevel'] ?? '',
    );
  }

  Map<String,dynamic> languagesToJson(Language language){
    Map<String,dynamic> data={
      'language':language.language ,
      'level':language.level,
    };
    return data;
  }

  static Language languageFromJson(Map<String, dynamic> json) {
    return Language(
      json['language'] ?? '',
      json['level'] ?? 1,
    );
  }
}
