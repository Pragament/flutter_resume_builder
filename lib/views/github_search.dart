import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/shared_preferences.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class GitHubSearch extends ConsumerStatefulWidget {
  const GitHubSearch({super.key});

  @override
  ConsumerState<GitHubSearch> createState() => _GitHubSearchConsumerState();
}

class _GitHubSearchConsumerState extends ConsumerState<GitHubSearch> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController _refreshController = StreamController();
  bool _loadingRepos = true;
  bool _gettingMoreRepos = false;
  bool _moreReposAvailable = true;
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _repos = [];
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? selectedLicense;
  DateTime? updatedFromDate;
  DateTime? updatedToDate;
  DateTime? pushedFromDate;
  DateTime? pushedToDate;
  int? minStars;
  int? minWatchers;
  int? minForks;
  int? minIssues;
  int? maxStars;
  int? maxWatchers;
  int? maxForks;
  int? maxIssues;

  @override
  void initState() {
    super.initState();
    _getRepos();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.sizeOf(context).height * 0.25;
      if (maxScroll - currentScroll <= delta) {
        _getMoreRepos();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.close();
    super.dispose();
  }

  _getRepos() async {
    Query q = _firestore
        .collection('Repositories')
        .orderBy('lastUpdated')
        .limit(_perPage);
    setState(() {
      _loadingRepos = true;
    });
    QuerySnapshot querySnapshot = await q.get();
    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    _repos = querySnapshot.docs;
    setState(() {
      _loadingRepos = false;
    });
  }

  _getMoreRepos() async {
    if (_moreReposAvailable == false || _gettingMoreRepos == true) {
      return;
    }

    Query q = _firestore
        .collection('Repositories')
        .orderBy('lastUpdated')
        .startAfterDocument(_lastDocument!)
        .limit(_perPage);
    setState(() {
      _gettingMoreRepos = true;
    });
    QuerySnapshot querySnapshot = await q.get();
    if (querySnapshot.docs.length < _perPage) {
      _moreReposAvailable = false;
    }
    _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    _repos.addAll(querySnapshot.docs);
    setState(() {
      _gettingMoreRepos = false;
    });
  }

  List<DocumentSnapshot> filterRepositories(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final repo = doc.data() as Map<String, dynamic>;
      final searchText = _searchController.text.toLowerCase();

      final name = repo['name'].toString().toLowerCase();
      if (searchText.isNotEmpty && !name.contains(searchText)) return false;

      if (selectedLicense != null && repo['license'] != selectedLicense) {
        return false;
      }

      if (updatedFromDate != null) {
        final updatedAt = (repo['updated_at'] as Timestamp).toDate();
        if (updatedAt.isBefore(updatedFromDate!)) return false;
      }
      if (updatedToDate != null) {
        final updatedAt = (repo['updated_at'] as Timestamp).toDate();
        if (updatedAt.isAfter(updatedToDate!)) return false;
      }
      if (pushedFromDate != null) {
        final pushedAt = (repo['pushed_at'] as Timestamp).toDate();
        if (pushedAt.isBefore(pushedFromDate!)) return false;
      }
      if (pushedToDate != null) {
        final pushedAt = (repo['pushed_at'] as Timestamp).toDate();
        if (pushedAt.isAfter(pushedToDate!)) return false;
      }

      if (minStars != null && (repo['stargazers_count'] ?? 0) < minStars!) {
        return false;
      }
      if (maxStars != null && (repo['stargazers_count'] ?? 0) > maxStars!) {
        return false;
      }

      if (minWatchers != null && (repo['watchers_count'] ?? 0) < minWatchers!) {
        return false;
      }
      if (maxWatchers != null && (repo['watchers_count'] ?? 0) > maxWatchers!) {
        return false;
      }

      if (minForks != null && (repo['forks_count'] ?? 0) < minForks!) {
        return false;
      }
      if (maxForks != null && (repo['forks_count'] ?? 0) > maxForks!) {
        return false;
      }

      if (minIssues != null && (repo['open_issues_count'] ?? 0) < minIssues!) {
        return false;
      }
      if (maxIssues != null && (repo['open_issues_count'] ?? 0) > maxIssues!) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        return;
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await getAccessToken();
      debugPrint('token: $token');
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/search/repositories?q=$query&order=desc'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'X-GitHub-Api-Version': '2022-11-28'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Search Response: ${response.body}');
        setState(() {
          searchResults = data['items'] ?? [];
          _repos.addAll(data['items']);
        });
        for (int index = 0; index < searchResults.length; index++) {
          final repo = data['items'][index];
          await _firestore.collection('Repositories').doc(repo['name']).set({
            'license': repo['license']?['name'] ?? 'No License',
            'owner': repo['owner']?['login'] ?? 'Unknown',
            'name': repo['name'] ?? '',
            'updated_at': repo['updated_at'] != null
                ? DateTime.parse(repo['updated_at'])
                : null,
            'pushed_at': repo['pushed_at'] != null
                ? DateTime.parse(repo['pushed_at'])
                : null,
            'homepage': repo['homepage'] ?? '',
            'stargazers_count': repo['stargazers_count'] ?? 0,
            'watchers_count': repo['watchers_count'] ?? 0,
            'forks_count': repo['forks_count'] ?? 0,
            'open_issues_count': repo['open_issues_count'] ?? 0,
            'description': repo['description'] ?? '',
            'url': repo['html_url'] ?? '',
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } else {
        debugPrint('Failed to load repositories: ${response.statusCode}');
        debugPrint('Error response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching repositories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showFilterBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 20.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter By',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Repo License',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedLicense,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      hint: const Text('Select License'),
                      items:
                          ['MIT', 'Apache-2.0', 'GPL-3.0', 'No License', null]
                              .map((license) => DropdownMenuItem(
                                    value: license,
                                    child: Text(license ?? 'Any License'),
                                  ))
                              .toList(),
                      onChanged: (value) =>
                          setState(() => selectedLicense = value),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildNumericFilter(
                    'Stars',
                    minStars,
                    maxStars,
                    (value) => setState(() => minStars = value),
                    (value) => setState(() => maxStars = value),
                  ),
                  SizedBox(height: 8.h),
                  _buildNumericFilter(
                    'Watchers',
                    minWatchers,
                    maxWatchers,
                    (value) => setState(() => minWatchers = value),
                    (value) => setState(() => maxWatchers = value),
                  ),
                  SizedBox(height: 8.h),
                  _buildNumericFilter(
                    'Forks',
                    minForks,
                    maxForks,
                    (value) => setState(() => minForks = value),
                    (value) => setState(() => maxForks = value),
                  ),
                  SizedBox(height: 8.h),
                  _buildNumericFilter(
                    'Issues',
                    minIssues,
                    maxIssues,
                    (value) => setState(() => minIssues = value),
                    (value) => setState(() => maxIssues = value),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Updated at',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'From',
                          updatedFromDate,
                          (date) => setState(() => updatedFromDate = date),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDatePicker(
                          'To',
                          updatedToDate,
                          (date) => setState(() => updatedToDate = date),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Pushed at',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'From',
                          pushedFromDate,
                          (date) => setState(() => pushedFromDate = date),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDatePicker(
                          'To',
                          pushedToDate,
                          (date) => setState(() => pushedToDate = date),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedLicense = null;
                              updatedFromDate = null;
                              updatedToDate = null;
                              pushedFromDate = null;
                              pushedToDate = null;
                              minStars = null;
                              minWatchers = null;
                              minForks = null;
                              minIssues = null;
                              maxStars = null;
                              maxWatchers = null;
                              maxForks = null;
                              maxIssues = null;
                            });
                            _refreshController.add(null);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey[600],
                            elevation: 0,
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('RESET'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _refreshController.add(null);
                            Navigator.pop(context);
                            this.setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('APPLY'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumericFilter(String label, int? minValue, int? maxValue,
      Function(int?) onMinChanged, Function(int?) onMaxChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Min',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: minValue?.toString(),
                  onChanged: (value) => onMinChanged(int.tryParse(value)),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Max',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: maxValue?.toString(),
                  onChanged: (value) => onMaxChanged(int.tryParse(value)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? value, Function(DateTime?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        title: Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value?.toString().split(' ')[0] ?? 'Not set',
          style: TextStyle(fontSize: 12.sp),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (date != null) onChanged(date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(1.sw, 60.h),
          child: BgGradientColor(
            child: AppBar(
              leading: BackButton(
                  color: Colors.white,
                  style: ButtonStyle(
                      iconSize: WidgetStatePropertyAll(
                    20.sp,
                  ))),
              actions: [
                IconButton(
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                  icon: const Icon(Icons.filter_alt),
                  color: Colors.white,
                ),
              ],
              title: SearchBar(
                autoFocus: false,
                controller: _searchController,
                hintText: 'Search for repositories',
                onSubmitted: (value) => _performSearch(value),
                onChanged: (value) => setState(() {}),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                trailing: [
                  _searchController.text.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.search),
                        )
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear)),
                ],
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: filterRepositories(_repos).length,
          itemBuilder: (context, index) {
            final repo = filterRepositories(_repos)[index].data()
                as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListTile(
                onTap: () {
                  launchUrl(
                    Uri.parse(repo['url']),
                    mode: LaunchMode.inAppWebView,
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(width: 0.75)),
                title: Text(repo['name'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(repo['description'] ?? ''),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text('${repo['stargazers_count'] ?? 0}'),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.fork_right,
                          size: 16.sp,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 4.w),
                        Text('${repo['forks_count'] ?? 0}'),
                        SizedBox(width: 16.w),
                        Icon(Icons.remove_red_eye_outlined,
                            size: 16.sp, color: AppColors.primaryColor),
                        SizedBox(width: 4.w),
                        Text('${repo['watchers_count'] ?? 0}'),
                      ],
                    ),
                    if (repo['updated_at'] != null)
                      Text(
                        'Updated: ${(repo['updated_at'] as Timestamp).toDate().toString().split('.').first}',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
