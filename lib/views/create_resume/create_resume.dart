import 'package:flutter/material.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/utils/routes/constants.dart';
import 'package:resume_builder_app/views/create_resume/children/education.dart';
import 'package:resume_builder_app/views/create_resume/children/experience.dart';
import 'package:resume_builder_app/views/create_resume/children/hobbies.dart';
import 'package:resume_builder_app/views/create_resume/children/personal_details.dart';
import 'package:resume_builder_app/views/create_resume/children/skills.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:resume_builder_app/views/home_screen.dart';
import 'package:resume_builder_app/views/view_cv/view_cv.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:resume_builder_app/views/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/providers/repo_provider.dart';


class CreateResume extends ConsumerStatefulWidget {
  CreateResume(
      {super.key,
      required this.templateDataModel,
      this.editResume = false,
      required this.cvId});
  final TemplateDataModel templateDataModel;
  final bool editResume;
  final int cvId;

  @override
  ConsumerState<CreateResume> createState() => _CreateResumeState();
}

class _CreateResumeState extends ConsumerState<CreateResume> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editResume) {
        setTemplateData(ref, widget.cvId, widget.templateDataModel);
      } else {
        initTemplate(ref, widget.cvId);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar().build(context, 'Resume'),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Consumer(
          builder: (context, ref, child) {
            final templateData =
                ref.watch(cvStateNotifierProvider)[widget.cvId];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sections',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                sectionSubTitle(
                    Icons.person, 'Personal Details', PersonalDetails(cvId: widget.cvId,),
                    showIcon: completedPersonalDetails(templateData)),
                sectionSubTitle(
                    Icons.school,
                    'Education',
                    EducationalDetails(
                      cvId: widget.cvId,
                    )),
                sectionSubTitle(Icons.work_history_outlined, 'Experience',
                     ExperienceDetails( cvId:  widget.cvId)),
                sectionSubTitle(
                    Icons.security_rounded, 'Skills',  SkillsDetails( cvId: widget.cvId,)),
                sectionSubTitle(Icons.group_work_outlined, 'Hobbies',
                     HobbiesDetails(cvId: widget.cvId,)),
              ],
            );
          },
        ),
      ),
      bottomSheet: InkWell(
        onTap: () {
          // 1. Get the current resume data
          final templateDataModel = ref.watch(cvStateNotifierProvider)[widget.cvId]!;

          // 2. Get highlighted repos from the provider
          final highlightedRepos = ref.read(repoProvider).repositories
              .where((repo) => repo.isHighlighted)
              .map((repo) => HighlightedProject(
                    name: repo.name,
                    url: repo.htmlUrl ?? '',
                    customDescription: repo.customDescription,
                    techStack: repo.language != null ? [repo.language!] : [],
                  ))
              .toList();

          // 3. Create a new TemplateDataModel with highlightedProjects
          final updatedModel = templateDataModel.copyWith(
            highlightedProjects: highlightedRepos,
          );

          // 4. Pass this to the resume preview
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ViewCv(
                templateData: Constants.convertToTemplateData(updatedModel),
                highlightedProjects: updatedModel.highlightedProjects,
              ),
            ),
          );
        },
        child: SizedBox(
          width: 1.sw,
          height: 70.h,
          child: CustomButton(
            title: 'View CV',
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }

  bool completedPersonalDetails(TemplateDataModel? dataModel) {
    if (dataModel != null) {
      return dataModel.fullName.isNotEmpty &&
          dataModel.email != null &&
          dataModel.email!.isNotEmpty &&
          dataModel.phoneNumber != null &&
          dataModel.phoneNumber!.isNotEmpty &&
          dataModel.currentPosition != null &&
          dataModel.country != null &&
          dataModel.street != null &&
          dataModel.address != null &&
          dataModel.bio != null;
    } else {
      return false;
    }
  }

  Widget sectionSubTitle(IconData icon, String title, Widget child,
      {bool showIcon = false}) {
    return SizedBox(
      width: 1.sw,
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => child));
        },
        child: Card(
          elevation: 2,
          margin: EdgeInsets.only(top: 8.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
          child: Padding(
            padding: EdgeInsets.only(
                top: 8.0.h, bottom: 12.h, left: 8.w, right: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8.sp),
                          child: BgGradientColor(
                              child: Padding(
                            padding: EdgeInsets.all(4.0.sp),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ))),
                      SizedBox(
                        width: 8.w,
                      ),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontSize: 16.sp,
                                color: Colors.black.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: showIcon,
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20.sp,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
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
