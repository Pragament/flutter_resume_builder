import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/local_database/local_db.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';
import 'package:resume_builder_app/models/UserResume.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/create_resume/create_resume.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {


  List<UserResume> userResumes=[UserResume(resumeTitle: "Flutter Developer",name: "Rehaman Shaik",email: 'srehaman234@gmail.com')];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar().build(context,'Home',firstPage: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w,vertical: 8.h),
        child: ListView.separated(
            separatorBuilder: (context,index) => SizedBox(height: 8.h,),
            itemCount: userResumes.length,
            itemBuilder: (context,index){
              return userResumeWidget(userResumes[index]);
            },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          await LocalDB.addTemplateData(TemplateDataModel());
           setIndex(ref);
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CreateResume()));
        },
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.add,color: Colors.white,size: 20.sp,),
      ),
    );
  }

  Widget userResumeWidget(UserResume userResume) {
    return SizedBox(
      width: 1.sw,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.sp)
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35.sp,
                        backgroundColor: AppColors.primaryColor,
                        child: Icon(Icons.person,color: Colors.white,size: 50.sp,),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(userResume.resumeTitle ?? "No Title",style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18.sp,fontWeight: FontWeight.w600),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.person,color: Colors.black.withOpacity(0.5),size: 16.sp,),
                          SizedBox(width: 4.w,),
                          Text(userResume.name ?? "No Name",style: Theme.of(context).textTheme.headlineSmall,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.email,color: Colors.black.withOpacity(0.5),size: 16.sp,),
                          SizedBox(width: 4.w,),
                          Text(userResume.email ?? "No Name",style: Theme.of(context).textTheme.headlineSmall,),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  iconTextButton(Icon(Icons.edit,color: Colors.white,size: 20.sp,),"Edit CV",(){}),
                  SizedBox(width: 16.w,),
                  iconTextButton(Icon(Icons.remove_red_eye_rounded,color: Colors.white,size: 20.sp,),"View Cv",(){}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconTextButton(Icon icon,String title,VoidCallback onPressed) {
    return Expanded(
      child: SizedBox(
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(AppColors.primaryColor)
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 8.w,),
              Text(title,style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white,fontSize: 14.sp,height: 0.7.h),)
            ],
          ),
        ),
      ),
    );
  }
}
