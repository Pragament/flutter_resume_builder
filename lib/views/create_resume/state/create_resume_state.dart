import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';
import 'package:resume_builder_app/views/create_resume/children/hobbies.dart';

  final loader= StateProvider<bool>((ref)=> false);
  final templateDataModel= StateProvider<TemplateDataModel>((ref) => TemplateDataModel());

  void setTemplateData(WidgetRef ref,TemplateDataModel data){
    ref.read(templateDataModel.notifier).state=
        ref.read(templateDataModel.notifier).state.
        copyWith(fullName: data.fullName,currentPosition: data.currentPosition,
            street:data.street,address: data.address,country: data.country,
            email: data.email,phoneNumber: data.phoneNumber,backgroundImage: data.bio);
  }

  void setTemplateEducationData(WidgetRef ref,List<Education> data){
    ref.read(templateDataModel.notifier).state=
    ref.read(templateDataModel.notifier).state.copyWith(educationDetails:data);
  }

void setTemplateExperienceData(WidgetRef ref,List<ExperienceData> data){
  ref.read(templateDataModel.notifier).state=
      ref.read(templateDataModel.notifier).state.copyWith(experience:data);
  }

void setSkills(WidgetRef ref,List<Language> data){
  ref.read(templateDataModel.notifier).state=
      ref.read(templateDataModel.notifier).state.copyWith(languages:data);
}

    void setHobbiesDetails(WidgetRef ref,List<String> hobbies){
      ref.read(templateDataModel.notifier).state=
          ref.read(templateDataModel.notifier).state.copyWith(hobbies:hobbies);
    }

