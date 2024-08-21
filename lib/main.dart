import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:resume_builder_app/data/data.dart';
import 'package:resume_builder_app/utils/app_themes.dart';
import 'package:resume_builder_app/views/home_screen.dart';
import 'package:resume_builder_app/views/sample_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const  ProviderScope(child:MyApp(),));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(MediaQuery.of(context).size.width ,MediaQuery.of(context).size.height),
        builder: (context,child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppThemes().lightTheme,
            home: HomeScreen(),
          );
        }
    );
  }
}
