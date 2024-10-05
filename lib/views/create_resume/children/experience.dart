import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/shared_preferences.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<Map<String, dynamic>> repoNames =
      []; // To store repo names and check status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final experienceDetails = ref.watch(templateDataModel).experience;
      experiences.addAll(experienceDetails);
      _initializeControllers();
      setState(() {});
    });
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
        TextEditingController(text: experience.experienceEndDate),
      ];
    }).toList();
  }

  @override
  void dispose() {
    for (var controllerList in controllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> callGitHubApi() async {
    const String githubApiUrl = 'https://api.github.com/user/repos';
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse(githubApiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      setState(() {
        repoNames = data.map((repo) {
          final createdAt = DateTime.parse(repo['created_at']);
          final updatedAt = DateTime.parse(repo['updated_at']);

          return {
            'name': repo['name'],
            'description': repo['description'] ?? "No description provided",
            'created_at': createdAt
                .toLocal()
                .toString()
                .split(' ')[0], // Format date only
            'updated_at': updatedAt
                .toLocal()
                .toString()
                .split(' ')[0], // Format date only
            'selected': false, // Checkbox selection status
          };
        }).toList();
      });

      showRepoSelectionDialog((selectedRepos) {
        if (selectedRepos.isNotEmpty) {
          setState(() {
            for (int i = 0; i < selectedRepos.length; i++) {
              if (i < controllers.length) {
                controllers[i][0].text = selectedRepos[i]['name'];
                controllers[i][2].text = selectedRepos[i]['created_at'];
                if (controllers[i].length > 4) {
                  controllers[i][4].text = selectedRepos[i]['description'];
                  controllers[i][5].text = selectedRepos[i]['updated_at'];
                }
              } else {
                experiences.add(ExperienceData(
                  experienceTitle: selectedRepos[i]['name'],
                  experienceLocation: '',
                  experiencePeriod: selectedRepos[i]['created_at'],
                  experiencePlace: '',
                  experienceDescription: selectedRepos[i]['description'],
                  experienceEndDate: selectedRepos[i]['updated_at'],
                ));
                controllers.add([
                  TextEditingController(text: selectedRepos[i]['name']),
                  TextEditingController(),
                  TextEditingController(text: selectedRepos[i]['created_at']),
                  TextEditingController(),
                  TextEditingController(text: selectedRepos[i]['description']),
                  TextEditingController(text: selectedRepos[i]['updated_at']),
                ]);
              }
            }
          });
        }
      });
    } else {
      CustomPopups.showSnackBar(context, "API Call Failed", Colors.red);
    }
  }

  void showRepoSelectionDialog(
      Function(List<Map<String, dynamic>>) onImportSelectedRepos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Repositories"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: repoNames.map((repo) {
                    return CheckboxListTile(
                      title: Text(repo['name']),
                      value: repo['selected'],
                      onChanged: (bool? value) {
                        setState(() {
                          repo['selected'] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    CustomPopups.showSnackBar(
                        context, "Selection Cancelled", Colors.red);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Get the selected repositories
                    final selectedRepos = repoNames
                        .where((repo) => repo['selected'] == true)
                        .toList();

                    // Pass selected repos back to the parent using the callback
                    onImportSelectedRepos(selectedRepos);

                    Navigator.of(context).pop();
                    CustomPopups.showSnackBar(
                        context,
                        selectedRepos.isNotEmpty
                            ? "Selected: ${selectedRepos.map((r) => r['name']).join(', ')}"
                            : "No Repos Selected",
                        Colors.green);
                  },
                  child: const Text("Import"),
                ),
              ],
            );
          },
        );
      },
    );
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
                          experienceEndDate: '',
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
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppColors.primaryColor),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BgGradientColor(
            borderRadius: BorderRadius.circular(30.sp),
            child: IconButton(
              onPressed: () async {
                List<ExperienceData> expData = [];
                for (int i = 0; i < experiences.length; i++) {
                  List<TextEditingController> controllersIndex = controllers[i];
                  expData.add(ExperienceData(
                      experienceTitle: controllersIndex[0].text,
                      experiencePlace: controllersIndex[3].text,
                      experiencePeriod: controllersIndex[2].text,
                      experienceLocation: controllersIndex[1].text,
                      experienceDescription: controllersIndex[4].text,
                      experienceEndDate: controllersIndex[5].text));
                }
                await setTemplateExperienceData(ref, expData).whenComplete(() =>
                    CustomPopups.showSnackBar(
                        context, "Successfully Saved", Colors.green));
              },
              icon: Icon(
                Icons.check,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
          ),
          SizedBox(height: 10.sp),
          BgGradientColor(
            borderRadius: BorderRadius.circular(30.sp),
            child: IconButton(
              onPressed: () async {
                // Call the GitHub API and show the dialog
                await callGitHubApi();
              },
              icon: Icon(
                Icons.cloud_download,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
          ),
        ],
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
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
                    ..._buildExperienceFields(controllersForThisIndex, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExperienceFields(
      List<TextEditingController> controllersIndex, BuildContext context) {
    return [
      TextField(
        controller: controllersIndex[0],
        decoration: InputDecoration(
          labelText: "Experience Title",
          labelStyle: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.primaryColor),
        ),
      ),
      TextField(
        controller: controllersIndex[1],
        decoration: InputDecoration(
          labelText: "Experience Location",
          labelStyle: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.primaryColor),
        ),
      ),
      TextField(
        controller: controllersIndex[2],
        decoration: InputDecoration(
          labelText: "Experience Start Date",
          labelStyle: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.primaryColor),
        ),
      ),
      TextField(
        controller:
            controllersIndex[5], // Ensure this is the end date controller
        decoration: InputDecoration(
          labelText: "Experience End Date",
          labelStyle: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.primaryColor),
        ),
      ),
      TextField(
        controller: controllersIndex[3],
        decoration: InputDecoration(
          labelText: "Experience Place",
          labelStyle: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.primaryColor),
        ),
      ),
      TextField(
        controller: controllersIndex[4],
        maxLines: 5,
        decoration: InputDecoration(
          labelText: "Experience Description",
          labelStyle: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.primaryColor),
        ),
      ),
    ];
  }
}
