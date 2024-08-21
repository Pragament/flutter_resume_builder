import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:resume_builder_app/views/widgets/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationalDetails extends ConsumerStatefulWidget {
  const EducationalDetails({super.key});

  @override
  ConsumerState<EducationalDetails> createState() => _EducationalDetailsState();
}

class _EducationalDetailsState extends ConsumerState<EducationalDetails> {
  List<Education> data = [];
  List<TextEditingController> schoolLevelControllers = [];
  List<TextEditingController> schoolNameControllers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final educationDetails = ref.watch(templateDataModel).educationDetails;
      data.addAll(educationDetails);

      // Initialize controllers for each item
      schoolLevelControllers = List.generate(
        data.length,
            (index) => TextEditingController(text: data[index].schoolLevel),
      );
      schoolNameControllers = List.generate(
        data.length,
            (index) => TextEditingController(text: data[index].schoolName),
      );

      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the controllers to avoid memory leaks
    for (var controller in schoolLevelControllers) {
      controller.dispose();
    }
    for (var controller in schoolNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar().build(context, "Educational Details"),
      body: Padding(
        padding: EdgeInsets.all(12.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < data.length; i++) educationDetailsView(data[i], i),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        data.add(Education("", ""));
                        // Add new controllers for the new item
                        schoolLevelControllers.add(TextEditingController());
                        schoolNameControllers.add(TextEditingController());
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor),
                    ),
                    label: Text(
                      "Add",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: BgGradientColor(
        borderRadius: BorderRadius.circular(30.sp),
        child: IconButton(
          onPressed: () {
            List<Education> educData=[];
            for (int i=0;i<data.length;i++) {
              educData.add(Education(schoolLevelControllers[i].text, schoolNameControllers[i].text));
            }
            setTemplateEducationData(ref, educData);
          },
          icon: Icon(
            Icons.check,
            color: Colors.white,
            size: 40.sp,
          ),
        ),
      ),
    );
  }

  Widget educationDetailsView(Education education, int index) {
    return SizedBox(
      width: 1.sw,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 1.sw,
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.sp),
                  topRight: Radius.circular(8.sp),
                ),
                color: AppColors.primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Education ${index + 1}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        data.removeAt(index);
                        // Remove the corresponding controllers
                        schoolLevelControllers.removeAt(index);
                        schoolNameControllers.removeAt(index);
                      });
                    },
                    child: Icon(
                      CupertinoIcons.delete,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course/Degree',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: 1.sw,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: schoolLevelControllers[index],
                                  onEditingComplete: () => setState(() {}),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Degree Name",
                                    hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'College/University',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: 1.sw,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: schoolNameControllers[index],
                                  onEditingComplete: () => setState(() {}),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "College/University",
                                    hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
