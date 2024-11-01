import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/local_database/local_db.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';

class CVStateNotifier extends StateNotifier<Map<int, TemplateDataModel>> {
  CVStateNotifier() : super({});

  void updateCV(int id, TemplateDataModel data) {
    state = {
      ...state,
      id: data,
    };
  }

  TemplateDataModel getCV(int id) {
    return state[id] ?? TemplateDataModel();
  }
}

final cvStateNotifierProvider =
    StateNotifierProvider<CVStateNotifier, Map<int, TemplateDataModel>>(
        (ref) => CVStateNotifier());

final loader = StateProvider<bool>((ref) => false);
final templateDataIndex = StateProvider<int>((ref) => 0);

void setUserResumes(WidgetRef ref, List<TemplateDataModel> resumes) async {
  final notifier = ref.read(cvStateNotifierProvider.notifier);
  for (int i = 0; i < resumes.length; i++) {
    notifier.updateCV(i, resumes[i]);
  }
}

void setIndex(WidgetRef ref, int index) async {
  ref.read(templateDataIndex.notifier).state = index;
}

Future<void> setTemplateData(
    WidgetRef ref, int id, TemplateDataModel data) async {
  ref.read(cvStateNotifierProvider.notifier).updateCV(id, data);
  await LocalDB.updateTemplateData(data, ref);
}

void initTemplate(WidgetRef ref, int id) async {
  ref.read(cvStateNotifierProvider.notifier).updateCV(id, TemplateDataModel());
}

Future<void> setTemplateEducationData(
    WidgetRef ref, int id, List<Education> data) async {
  final currentData = ref.read(cvStateNotifierProvider.notifier).getCV(id);
  final updatedData = currentData.copyWith(educationDetails: data);
  ref.read(cvStateNotifierProvider.notifier).updateCV(id, updatedData);
  await LocalDB.updateTemplateData(updatedData, ref);
}

Future<void> setTemplateExperienceData(
    WidgetRef ref, int id, List<ExperienceData> data) async {
  final currentData = ref.read(cvStateNotifierProvider.notifier).getCV(id);
  final updatedData = currentData.copyWith(experience: data);
  ref.read(cvStateNotifierProvider.notifier).updateCV(id, updatedData);
  await LocalDB.updateTemplateData(updatedData, ref);
}

Future<void> setSkills(WidgetRef ref, int id, List<Language> data) async {
  final currentData = ref.read(cvStateNotifierProvider.notifier).getCV(id);
  final updatedData = currentData.copyWith(languages: data);
  ref.read(cvStateNotifierProvider.notifier).updateCV(id, updatedData);
  await LocalDB.updateTemplateData(updatedData, ref);
}

Future<void> setHobbiesDetails(
    WidgetRef ref, int id, List<String> hobbies) async {
  final currentData = ref.read(cvStateNotifierProvider.notifier).getCV(id);
  final updatedData = currentData.copyWith(hobbies: hobbies);
  ref.read(cvStateNotifierProvider.notifier).updateCV(id, updatedData);
  await LocalDB.updateTemplateData(updatedData, ref);
}

class CVWidget extends ConsumerWidget {
  final int cvId;

  CVWidget({required this.cvId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvData = ref.watch(cvStateNotifierProvider)[cvId];

    return Scaffold(
      appBar: AppBar(
        title: Text('CV $cvId'),
      ),
      body: Column(
        children: [
          Text('Full Name: ${cvData?.fullName}'),
          // Add more fields as needed
          ElevatedButton(
            onPressed: () {
              // Example of updating CV data
              final updatedData = cvData?.copyWith(fullName: 'New Name');
              ref
                  .read(cvStateNotifierProvider.notifier)
                  .updateCV(cvId, updatedData!);
            },
            child: Text('Update Name'),
          ),
        ],
      ),
    );
  }
}
