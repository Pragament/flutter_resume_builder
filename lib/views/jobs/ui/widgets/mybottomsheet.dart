import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/views/jobs/models/bottomsheetmodel.dart';
import 'package:resume_builder_app/views/jobs/providers/job_filter_provider.dart';
import 'package:resume_builder_app/views/jobs/providers/job_provider.dart';
class MyBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RangeValues _rangeValues = ref.watch(jobFilterProvider).salaryRange;
    final jobTypes = [
      "Full-time",
      "Part-time",
      "Contract",
      "Internship",
      "Temporary",
      "Commission"
    ];
    final selectedJobTypes = ref.watch(jobFilterProvider).selectedJobTypes;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              Text("Salary Estimate", style: Theme.of(context).textTheme.titleLarge),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  valueIndicatorTextStyle: TextStyle(color: Colors.white), // Tooltip text color
                  valueIndicatorColor: Colors.blueAccent, // Tooltip background color
                  showValueIndicator: ShowValueIndicator.always, // Always show value indicator
                ),
                child: RangeSlider(
                  min: 0,
                  max: 300000,
                  values: _rangeValues,
                  divisions: 100,
                  labels: RangeLabels(
                    _rangeValues.start.round().toString(),
                    _rangeValues.end.round().toString(),
                  ),
                  onChanged: (rangeValue) {
                    setState(() {
                      _rangeValues = rangeValue;
                    });
                    // Update the salary range in jobFilterProvider
                    ref.read(jobFilterProvider.notifier).updateSalaryRange(rangeValue);
                  },
                ),
              ),

              Text("Job Type", style: Theme.of(context).textTheme.titleLarge),
              Wrap(
                spacing: 8.0,
                children: jobTypes.map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: selectedJobTypes.contains(type),
                    onSelected: (isSelected) {
                      List<String> updatedTypes = List.from(selectedJobTypes);
                      isSelected ? updatedTypes.add(type) : updatedTypes.remove(type);
                      ref.read(jobFilterProvider.notifier).updateJobTypes(updatedTypes);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20,),
            //  ExperienceLevelWidget(),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  // Trigger job fetch with applied filters
                  ref.read(jobProvider.notifier).fetchJobs();
                  ref.read(myBottomSheetProvider.notifier).changeState();
                },
                child: Text("Apply Filters"),
              ),
            ],
          ),
        );
      },
    );
  }
}
