import 'package:flutter/material.dart';

class CustomPopups{
  static showSnackBar(BuildContext context,String content,Color bgColor){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(content,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16),),
          backgroundColor:bgColor,
          duration: const Duration(seconds: 1),
      )
    );
  }
}