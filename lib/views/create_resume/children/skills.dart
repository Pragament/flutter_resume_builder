import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/routes/app_colors.dart';
class SkillsDetails extends StatefulWidget {
  const SkillsDetails({super.key});

  @override
  State<SkillsDetails> createState() => _SkillsDetailsState();
}

class _SkillsDetailsState extends State<SkillsDetails> {
  List<Language> languages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar().build(context, "Skills"),
      body: Padding(
        padding: EdgeInsets.all(12.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < languages.length; i++)
                skillDetailsView(languages[i], i),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      languages.add(Language('', 1));
                      setState(() {});
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 40.sp,
        ),
        onPressed: () {
          // Save or submit the language data
        },
      ),
    );
  }

  Widget skillDetailsView(Language data, int index) {
    TextEditingController nameController = TextEditingController(text: data.language);
    int level = data.level;

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
                    'Skill ${index + 1}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {
                      languages.removeAt(index);
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
                      'Skill Name',
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
                                Icons.language,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Language Name",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onEditingComplete: () {
                                    languages[index]=Language(nameController.text,level);
                                    setState(() {

                                    });
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
                      'Proficiency Level',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Row(
                            children: [
                              Radio<int>(
                                value: i,
                                activeColor: AppColors.primaryColor,
                                groupValue: level,
                                onChanged: (value) {
                                  setState(() {
                                    languages[index]=Language(nameController.text,value ?? 1);
                                  });
                                },
                              ),
                              Text(
                                '$i',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                      ],
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