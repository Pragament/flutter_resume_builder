import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDB{

  ///keys
  static String dataModels='data_models';


  Future<SharedPreferences> getInstance()async{
    return SharedPreferences.getInstance();
  }

  static Future<List<TemplateDataModel>> getTemplatesData()async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> jsonList = sharedPreferences.getStringList(dataModels) ?? [];
    List<TemplateDataModel> data=[];
    for (var templateData in jsonList) {
      TemplateDataModel templateDataModel=TemplateDataModel.fromJson(jsonDecode(templateData));
      data.add(templateDataModel);
    }
    return data;
  }

  static Future<bool> addTemplateData(TemplateDataModel templateData) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> jsonList = sharedPreferences.getStringList(dataModels) ?? [];
    jsonList.add(jsonEncode(templateData.toJson()));
    return await sharedPreferences.setStringList(dataModels, jsonList);
  }

  static Future<bool> updateTemplateData(TemplateDataModel newTemplateData,WidgetRef ref) async {
    int index= ref.watch(templateDataIndex);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> jsonList = sharedPreferences.getStringList(dataModels) ?? [];
    if (index < 0 || index >= jsonList.length) {
      return false;
    }
    jsonList[index] = jsonEncode(newTemplateData.toJson());
    return await sharedPreferences.setStringList(dataModels, jsonList);
  }

}