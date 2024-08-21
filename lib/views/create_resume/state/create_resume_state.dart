import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

  final loader= StateProvider<bool>((ref)=> false);
  final templateData= StateProvider<TemplateData>((ref) => TemplateData(fullName: ''));

  void setTemplateData(WidgetRef ref,TemplateData data){
    ref.read(templateData.notifier).state=data;
  }

  void setTemplateEducationData(WidgetRef ref,Education data){
    ref.read(templateData.notifier);
  }

