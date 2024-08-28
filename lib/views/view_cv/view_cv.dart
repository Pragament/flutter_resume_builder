import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:resume_builder_app/main.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/view_cv/cv_types/business_cv.dart';
import 'package:resume_builder_app/views/view_cv/cv_types/classic_cv.dart';
import 'package:resume_builder_app/views/view_cv/cv_types/modern_cv.dart';
import 'package:resume_builder_app/views/view_cv/cv_types/technical_cv.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:pdf/widgets.dart' as pw;

import '../widgets/custom_button.dart';

class ViewCv extends StatefulWidget {
  const ViewCv({super.key,required this.templateData});
  final TemplateData templateData;

  @override
  State<ViewCv> createState() => _ViewCvState();
}

class _ViewCvState extends State<ViewCv> with SingleTickerProviderStateMixin {
  GlobalKey key=GlobalKey();
  late TabController tabController;
  double height=2000;

  @override
  void initState() {
    tabController=TabController(length: 4, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar(tabBar: tabBar(),).build(context, "CV"),
      body:TabBarView(
        controller: tabController,
          children: [
            ClassicCV(templateData: widget.templateData),
            ModernCv(templateData: widget.templateData),
            TechnicalCV(templateData: widget.templateData),
            BusinessCV(templateData: widget.templateData),
          ]
      ),
    );
  }


  Widget tabBar(){
    return TabBar(
        controller: tabController,
        dividerHeight: 0,
        indicatorColor: Colors.white,
        tabs: [
          Tab(child: Text('Classic',style: TextStyle(color: Colors.white,fontSize: 12.sp),),),
          Tab(child: Text('Modern',style: TextStyle(color: Colors.white,fontSize: 12.sp),),),
          Tab(child: Text('Technical',style: TextStyle(color: Colors.white,fontSize: 12.sp),),),
          Tab(child: Text('Business',style: TextStyle(color: Colors.white,fontSize: 12.sp),),),
        ]);
  }
}
