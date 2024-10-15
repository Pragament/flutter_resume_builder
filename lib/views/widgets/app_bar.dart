import 'package:flutter/material.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class CustomAppBar extends AppBar {
  CustomAppBar({super.key,this.tabBar});
  Widget? tabBar;
  PreferredSize build(BuildContext context,String title,
      {bool firstPage = false}) {
    return PreferredSize(
      preferredSize: Size(1.sw,tabBar!=null? 110.h: 60.h),
      child: BgGradientColor(
        child:Column(
          children: [
            AppBar(
              leading: firstPage? null : IconButton(onPressed: ()=>Navigator.pop(context), icon:Icon(Icons.arrow_back,color: Colors.white,size: 20.sp,)),
              centerTitle: true,
              title: Text(title,style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20.sp,color: Colors.white),),
              backgroundColor: Colors.transparent,),
            tabBar??SizedBox(height: 0,),
          ],
        )
      ),
    );
  }
}

