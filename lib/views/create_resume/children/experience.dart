import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';

import '../../widgets/pop_ups/custom_popups.dart';
import '../state/create_resume_state.dart';


class ExperienceDetails extends ConsumerStatefulWidget {
  const ExperienceDetails({super.key});

  @override
  ConsumerState<ExperienceDetails> createState() => _ExperienceDetailsState();
}

class _ExperienceDetailsState extends ConsumerState<ExperienceDetails> {
  List<ExperienceData> experiences = [];
  List<List<TextEditingController>> controllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final experienceDetails = ref.watch(templateDataModel).experience;
      experiences.addAll(experienceDetails);
      _initializeControllers();
      setState(() {});
    });
    // Initialize the controllers list based on existing experiences
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers = experiences.map((experience) {
      return [
        TextEditingController(text: experience.experienceTitle),
        TextEditingController(text: experience.experienceLocation),
        TextEditingController(text: experience.experiencePeriod),
        TextEditingController(text: experience.experiencePlace),
        TextEditingController(text: experience.experienceDescription),
      ];
    }).toList();
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controllerList in controllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar().build(context, "Experience Details"),
      body: Padding(
        padding: EdgeInsets.all(12.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < experiences.length; i++)
                experienceDetailsView(experiences[i], i),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        experiences.add(ExperienceData(
                          experienceTitle: '',
                          experienceLocation: '',
                          experiencePeriod: '',
                          experiencePlace: '',
                          experienceDescription: '',
                        ));
                        controllers.add([
                          TextEditingController(),
                          TextEditingController(),
                          TextEditingController(),
                          TextEditingController(),
                          TextEditingController(),
                        ]);
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
          onPressed: ()async{
            List<ExperienceData> expData=[];
            for (int i=0;i<experiences.length;i++) {
              List<TextEditingController> controllersIndex=controllers[i];
              expData.add(
                  ExperienceData(experienceTitle:controllersIndex[0].text,
                                 experiencePlace: controllersIndex[3].text,
                                 experiencePeriod: controllersIndex[2].text,
                                 experienceLocation: controllersIndex[1].text,
                                 experienceDescription: controllersIndex[4].text, ));
            }
            await setTemplateExperienceData(ref, expData).whenComplete(()=>CustomPopups.showSnackBar(context,"Successfully Saved",Colors.green));
            // Save or submit the experience data
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



  Widget experienceDetailsView(ExperienceData data, int index) {
    final controllersForThisIndex = controllers[index];

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
                    'Experience ${index + 1}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        experiences.removeAt(index);
                        controllers.removeAt(index);
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
                      'Title',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      icon: Icons.work,
                      controller: controllersForThisIndex[0],
                      hintText: "Experience Title",
                      onChanged: (value) {
                        data.experienceTitle = value;
                      },
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      icon: Icons.language,
                      controller: controllersForThisIndex[1],
                      hintText: "Country Name",
                      onChanged: (value) {
                        data.experienceLocation = value;
                      },
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Period',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      icon: Icons.calendar_today,
                      controller: controllersForThisIndex[2],
                      hintText: "Experience Period",
                      onChanged: (value) {
                        data.experiencePeriod = value;
                      },
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Place',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      icon: CupertinoIcons.location_solid,
                      controller: controllersForThisIndex[3],
                      hintText: "Remote / City Name",
                      onChanged: (value) {
                        data.experiencePlace = value;
                      },
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                        child: TextField(
                          controller: controllersForThisIndex[4],
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Experience Description",
                            hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                          ),
                          onChanged: (value) {
                            data.experienceDescription = value;
                          },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    IconData icon=Icons.edit
  }) {
    return SizedBox(
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
                icon,
                color: Colors.grey,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
