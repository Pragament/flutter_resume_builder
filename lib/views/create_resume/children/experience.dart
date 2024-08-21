import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';

class ExperienceDetails extends StatefulWidget {
  const ExperienceDetails({super.key});

  @override
  State<ExperienceDetails> createState() => _ExperienceDetailsState();
}

class _ExperienceDetailsState extends State<ExperienceDetails> {
  List<ExperienceData> experiences = [];

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
                      experiences.add(ExperienceData(
                        experienceTitle: '',
                        experienceLocation: '',
                        experiencePeriod: '',
                        experiencePlace: '',
                        experienceDescription: '',
                      ));
                      setState(() {});
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(AppColors.primaryColor),
                    ),
                    label: Text(
                      "Add",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: BgGradientColor(
        borderRadius: BorderRadius.circular(30.sp),
        child: IconButton(
          onPressed: () {
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
    TextEditingController titleController = TextEditingController(text: data.experienceTitle);
    TextEditingController locationController = TextEditingController(text: data.experienceLocation);
    TextEditingController periodController = TextEditingController(text: data.experiencePeriod);
    TextEditingController placeController = TextEditingController(text: data.experiencePlace);
    TextEditingController descriptionController = TextEditingController(text: data.experienceDescription);

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
                      experiences.removeAt(index);
                      setState(() {});
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 14.sp),
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
                                Icons.work,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Experience Title",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    data.experienceTitle = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Location',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 14.sp),
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
                                Icons.place,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: locationController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Country Name",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    data.experienceLocation = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Period',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 14.sp),
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
                                Icons.calendar_today,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: periodController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Experience Period",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    data.experiencePeriod = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Place',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 14.sp),
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
                                Icons.place,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: placeController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Remote / City Name",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    data.experiencePlace = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 14.sp),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: descriptionController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Experience Description",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    data.experienceDescription = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

