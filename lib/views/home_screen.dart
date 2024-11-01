import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/data/data.dart';
import 'package:resume_builder_app/local_database/local_db.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/create_resume/create_resume.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:resume_builder_app/views/view_cv/view_cv.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visibility_detector/visibility_detector.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    getTemplateModels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('MyWidget'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction != 0.0) {
          getTemplateModels();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar().build(context, 'Home', firstPage: true),
        body: Consumer(
          builder: (context, ref, child) {
            final userResumes = ref.watch(cvStateNotifierProvider);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 0.h),
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                  height: 8.h,
                ),
                itemCount: userResumes.length,
                itemBuilder: (context, index) {
                  return userResumeWidget(userResumes[index]!, index);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await LocalDB.addTemplateData(TemplateDataModel());
            List<TemplateDataModel> models = await LocalDB.getTemplatesData();
            setIndex(ref, models.length - 1);
            TemplateDataModel? model;
            if (models.isNotEmpty) {
              model = models[ref.watch(templateDataIndex)];
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateResume(
                      templateDataModel: model ?? TemplateDataModel(),
                      cvId: models.length - 1,
                    )));
          },
          backgroundColor: AppColors.primaryColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget userResumeWidget(TemplateDataModel userResume, int index) {
    return SizedBox(
      width: 1.sw,
      child: Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
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
                        backgroundImage: userResume.image != null
                            ? FileImage(File(userResume.image!))
                            : null,
                        child: userResume.image == null
                            ? Icon(
                                Icons.person,
                                size: 50.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userResume.currentPosition != null &&
                                    userResume.currentPosition!.isNotEmpty
                                ? userResume.currentPosition.toString()
                                : "Untitled ${index + 1}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.black.withOpacity(0.5),
                            size: 16.sp,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            userResume.fullName.isNotEmpty
                                ? userResume.fullName
                                : "",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.email,
                            color: Colors.black.withOpacity(0.5),
                            size: 16.sp,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            userResume.email != null &&
                                    userResume.email!.isNotEmpty
                                ? userResume.email.toString()
                                : "",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  iconTextButton(
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      "Edit CV", () {
                    setIndex(ref, index);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CreateResume(
                              templateDataModel: userResume,
                              editResume: true,
                              cvId: index,
                            )));
                  }),
                  SizedBox(
                    width: 16.w,
                  ),
                  iconTextButton(
                      Icon(
                        Icons.remove_red_eye_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      "View Cv", () {
                    TemplateData templateData =
                        convertToTemplateData(userResume);
                    print(templateData.image);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ViewCv(
                              templateData: templateData,
                            )));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconTextButton(Icon icon, String title, VoidCallback onPressed) {
    return Expanded(
      child: SizedBox(
        child: TextButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColors.primaryColor)),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(
                width: 8.w,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white, fontSize: 14.sp, height: 0.7.h),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getTemplateModels() async {
    List<TemplateDataModel> userResumes = await LocalDB.getTemplatesData();
    setUserResumes(ref, userResumes);
  }

  TemplateData convertToTemplateData(TemplateDataModel userResume) {
    print(userResume.educationDetails.length);
    return TemplateData(
        fullName: userResume.fullName,
        email: userResume.email == null
            ? null
            : userResume.email!.isNotEmpty
                ? userResume.email
                : null,
        phoneNumber: userResume.phoneNumber == null
            ? null
            : userResume.phoneNumber!.isNotEmpty
                ? userResume.phoneNumber
                : null,
        currentPosition: userResume.currentPosition == null
            ? null
            : userResume.currentPosition!.isNotEmpty
                ? userResume.currentPosition
                : null,
        country: userResume.country == null
            ? null
            : userResume.country!.isNotEmpty
                ? userResume.country
                : null,
        address: userResume.address == null
            ? null
            : userResume.address!.isNotEmpty
                ? userResume.address
                : null,
        street: userResume.street == null
            ? null
            : userResume.street!.isNotEmpty
                ? userResume.street
                : null,
        bio: userResume.bio == null
            ? null
            : userResume.bio!.isNotEmpty
                ? userResume.bio
                : null,
        experience: userResume.experience.isNotEmpty
            ? userResume.experience
            : data.experience,
        educationDetails: userResume.educationDetails.isNotEmpty
            ? userResume.educationDetails
            : data.educationDetails,
        hobbies:
            userResume.hobbies.isNotEmpty ? userResume.hobbies : data.hobbies,
        languages: userResume.languages.isNotEmpty
            ? userResume.languages
            : data.languages,
        backgroundImage:
            'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        image: userResume.image);
  }
}

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}
