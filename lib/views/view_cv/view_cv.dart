
import 'package:flutter/material.dart';

import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:resume_builder_app/views/view_cv/cv_types/classic_cv.dart';
import 'package:resume_builder_app/views/view_cv/cv_types/modern_cv.dart';

import 'package:resume_builder_app/views/widgets/app_bar.dart';


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
    tabController=TabController(length: 2, vsync: this);
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
            ResumeScreen(templateData: widget.templateData),
            ResumeScreen2(templateData: widget.templateData),
            
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
          
        ]);
  }
}
