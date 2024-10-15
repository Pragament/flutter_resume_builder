import 'package:flutter_resume_template/flutter_resume_template.dart';

import '../../data/data.dart';
import '../../models/TemplateDataModel.dart';

class Constants {
  static TemplateData convertToTemplateData(TemplateDataModel userResume) {
    return TemplateData(
      fullName: userResume.fullName,
      email: userResume.email == null
          ? null
          : userResume.email!.isNotEmpty
              ? userResume.email
              : null,
      phoneNumber: userResume.phoneNumber == null
          ? null
          : userResume.phoneNumber!.isNotEmpty
              ? userResume.phoneNumber
              : null,
      currentPosition: userResume.currentPosition == null
          ? null
          : userResume.currentPosition!.isNotEmpty
              ? userResume.currentPosition
              : null,
      country: userResume.country == null
          ? null
          : userResume.country!.isNotEmpty
              ? userResume.country
              : null,
      address: userResume.address == null
          ? null
          : userResume.address!.isNotEmpty
              ? userResume.address
              : null,
      street: userResume.street == null
          ? null
          : userResume.street!.isNotEmpty
              ? userResume.street
              : null,
      bio: userResume.bio == null
          ? null
          : userResume.bio!.isNotEmpty
              ? userResume.bio
              : null,
      experience: userResume.experience.isNotEmpty
          ? userResume.experience
          : data.experience,
      educationDetails: userResume.educationDetails.isNotEmpty
          ? userResume.educationDetails
          : data.educationDetails,
      hobbies:
          userResume.hobbies.isNotEmpty ? userResume.hobbies : data.hobbies,
      languages: userResume.languages.isNotEmpty
          ? userResume.languages
          : data.languages,
      backgroundImage:
          'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      image: (userResume.image != null)
          ? userResume.image
          : 'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    );
  }
}
