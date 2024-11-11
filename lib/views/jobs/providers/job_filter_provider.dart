// job_filter_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobFilterState {
  final List<String> selectedJobTypes;
  final RangeValues salaryRange;
  final String searchQuery;

  JobFilterState({
    this.selectedJobTypes = const [],
    this.salaryRange = const RangeValues(0, 300000),
    this.searchQuery='',
  });
}

class JobFilterNotifier extends StateNotifier<JobFilterState> {
  JobFilterNotifier() : super(JobFilterState());

  void updateJobTypes(List<String> types) {
    state = JobFilterState(
      selectedJobTypes: types,
      salaryRange: state.salaryRange,
    );
  }

  void updateSalaryRange(RangeValues range) {
    state = JobFilterState(
      selectedJobTypes: state.selectedJobTypes,
      salaryRange: range,
    );
  }
  void updateSearch(String query)
  {
    state= JobFilterState(
      selectedJobTypes:state.selectedJobTypes,
      salaryRange:state.salaryRange,
      searchQuery: query.isNotEmpty? query:'',
    );
  }
}

final jobFilterProvider = StateNotifierProvider<JobFilterNotifier, JobFilterState>(
      (ref) => JobFilterNotifier(),
);

