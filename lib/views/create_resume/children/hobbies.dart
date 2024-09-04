import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';

import '../../widgets/pop_ups/custom_popups.dart';

class HobbiesDetails extends ConsumerStatefulWidget {
  const HobbiesDetails({super.key});

  @override
  ConsumerState<HobbiesDetails> createState() => _HobbiesDetailsState();
}

class _HobbiesDetailsState extends ConsumerState<HobbiesDetails> {
  List<String> hobbies = [];
  List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hobbies.addAll(ref.read(templateDataModel).hobbies);
      _initializeControllers();
      setState(() {});
    });
  }

  void _initializeControllers() {
    nameControllers = hobbies.map((hobby) {
      return TextEditingController(text: hobby);
    }).toList();
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar().build(context, "Hobbies"),
      body: Padding(
        padding: EdgeInsets.all(12.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < hobbies.length; i++)
                hobbyDetailsView(hobbies[i], i),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        hobbies.add("");
                        nameControllers.add(TextEditingController());
                      });
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
        onPressed: ()async{
          List<String> hobbiesData=[];
          for(int i=0;i<hobbies.length;i++){
            hobbiesData.add(nameControllers[i].text);
          }
          await setHobbiesDetails(ref, hobbiesData).whenComplete(()=>CustomPopups.showSnackBar(context,"Successfully Saved",Colors.green));
          // Save or submit the hobbies data
        },
      ),
    );
  }

  Widget hobbyDetailsView(String data, int index) {
    final nameController = nameControllers[index];

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
                    'Hobby ${index + 1}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        hobbies.removeAt(index);
                        nameControllers[index].dispose();
                        nameControllers.removeAt(index);
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
                      'Hobby',
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
                                Icons.accessibility_new_sharp,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Music, Games..",
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      hobbies[index] = value;
                                    });
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
