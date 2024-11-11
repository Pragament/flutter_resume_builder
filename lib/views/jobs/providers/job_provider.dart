import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/jobs_model.dart';
import 'job_filter_provider.dart';

class JobNotifier extends StateNotifier<List<Job>> {
  final Ref ref;

  JobNotifier(this.ref) : super([]);

  Future<void> fetchJobs() async {
    try {
      // Fetch the filters
      final filters = ref.read(jobFilterProvider);
      final selectedJobTypes = filters.selectedJobTypes;
      final salaryRange = filters.salaryRange;
      final searchQuery = filters.searchQuery;
      // Fetch jobs from API
      final response = await http.get(
          Uri.parse('https://staticapis.pragament.com/job_portal/jobs.json')
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> records = data['jobs'];
        List<Job> allJobs = records.map((json) => Job.fromJson(json)).toList();
        // Filtered job list based on search query
        List<Job> searchedJobList =searchQuery.isEmpty?allJobs: allJobs.where((job) {
          final query = searchQuery.isNotEmpty? searchQuery.toLowerCase():'';
          final titleMatches = job.title.toLowerCase().contains(query);
          final locationMatches = job.location.toLowerCase().contains(query);
          return titleMatches || locationMatches;
        }).toList();
        // Filter jobs based on selected job types and salary range
       List<Job> filteredJobList = searchedJobList.where((job) { //add more filtered data
          final matchesType = selectedJobTypes.isEmpty || selectedJobTypes.contains(job.employmentType);
          final matchesSalary = job.salary.min >= salaryRange.start && job.salary.max <= salaryRange.end;
          return matchesType && matchesSalary;
        }).toList();
        // Update the state with the filtered jobs
        state = filteredJobList;
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }
}

final jobProvider = StateNotifierProvider<JobNotifier, List<Job>>((ref) => JobNotifier(ref));
// Provider for search query

