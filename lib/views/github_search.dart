import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/shared_preferences.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../data/git_operations.dart';
import 'repo_list_screen.dart';

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
  int? minImages;
  int? maxStars;
  int? maxWatchers;
  int? maxForks;
  int? maxIssues;
  int? maxImages;
  bool? hasGif;
  int get activeFilterCount {
    int count = 0;
    if (selectedLicense != null) count++;
    if (hasGif != null) count++;
    if (minStars != null || maxStars != null) count++;
    if (minWatchers != null || maxWatchers != null) count++;
    if (minForks != null || maxForks != null) count++;
    if (minIssues != null || maxIssues != null) count++;
    if (minImages != null || maxImages != null) count++;
    if (updatedFromDate != null || updatedToDate != null) count++;
    if (pushedFromDate != null || pushedToDate != null) count++;
    return count;
  }

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
        .orderBy('last_updated')
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
        .orderBy('last_updated')
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

  Future<List<DocumentSnapshot>> getFilteredRepos() async {
    Query query = _firestore.collection('Repositories');

    if (hasGif != null) {
      query = query.where('has_gif', isEqualTo: hasGif);
    }

    if (selectedLicense != null) {
      query = query.where('license', isEqualTo: selectedLicense);
    }

    query = query.orderBy('last_updated').limit(_perPage * 2);

    QuerySnapshot snapshot = await query.get();

    final serverFiltered = snapshot.docs.where((doc) {
      final repo = doc.data() as Map<String, dynamic>;

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

      if (minImages != null &&
          ((repo['image_links'] as List).length) < minImages!) {
        return false;
      }
      if (maxImages != null &&
          ((repo['image_links'] as List).length) > maxImages!) {
        return false;
      }

      return true;
    }).toList();

    return serverFiltered;
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
        QuerySnapshot querySnapshot = await _firestore
            .collection('Repositories')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: '$query\uF7FF')
            .get();
        setState(() {
          searchResults = data['items'] ?? [];
          _repos.addAll(querySnapshot.docs);
        });
        for (int index = 0; index < searchResults.length; index++) {
          final repo = searchResults[index];
          final response2 = await http.get(
            Uri.parse(
                'https://api.github.com/repos/${repo['owner']?['login']}/${repo['name']}/readme'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/vnd.github.v3+json',
              'X-GitHub-Api-Version': '2022-11-28'
            },
          );
          if (response2.statusCode == 200) {
            final data2 = json.decode(response2.body);
            debugPrint('Search Response2: ${response2.body}');
            String base64Content = data2['content'].replaceAll('\n', '');
            String decodedContent = utf8.decode(base64.decode(base64Content));
            debugPrint('Decoded Content: $decodedContent');
            final imageLinkRegex = RegExp(
                r'!\[.*?\]\((https?:\/\/[^\s\)]+(?:\.(png|jpg|jpeg|gif|svg))?)\)|<img[^>]+src=[\"](https?:\/\/.*?)[\"]');
            bool temp = false;
            final imageLinks = imageLinkRegex
                .allMatches(decodedContent)
                .map((match) {
                  String? url =
                      match.group(1) ?? match.group(2) ?? match.group(3);
                  if (url != null) {
                    if (url.toLowerCase().contains('.gif') ||
                        url.toLowerCase().endsWith('.gif')) {
                      temp = true;
                    }
                    return convertToRawGitHubUrl(url);
                  }
                  return null;
                })
                .where((url) => url != null && url.isNotEmpty)
                .cast<String>()
                .toList();

            debugPrint("Extracted Image Links:");
            for (var link in imageLinks) {
              debugPrint(link);
            }

            await _firestore
                .collection('Repositories')
                .doc("${repo['owner']?['login']}-${repo['name']}")
                .set({
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
              'last_updated': FieldValue.serverTimestamp(),
              'image_links': imageLinks,
              'has_gif': temp,
            }, SetOptions(merge: true));
          }
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
                SizedBox(height: 15.h),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        'Repo License',
                        style:
                            TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                          hint: const Text('Select License'),
                          items: [
                            'MIT',
                            'Apache-2.0',
                            'GPL-3.0',
                            'No License',
                            null
                          ]
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
                      Text(
                        'Contains GIF',
                        style:
                            TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<bool?>(
                          value: hasGif,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                          hint: const Text('Select your option'),
                          items: [null, true, false]
                              .map((gif) => DropdownMenuItem(
                                    value: gif,
                                    child: Text(gif == null
                                        ? 'Any'
                                        : (gif ? 'Yes' : 'No')),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => hasGif = value),
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
                      _buildNumericFilter(
                        'Images',
                        minImages,
                        maxImages,
                        (value) => setState(() => minImages = value),
                        (value) => setState(() => maxImages = value),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Updated at',
                        style:
                            TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
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
                        style:
                            TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
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
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
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
                            minImages = null;
                            maxStars = null;
                            maxWatchers = null;
                            maxForks = null;
                            maxIssues = null;
                            maxImages = null;
                            hasGif = null;
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

  Widget buildImageWidget(String url,
      {double height = 100, double width = 100, fit = BoxFit.scaleDown}) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => SvgPicture.network(
        url,
        height: 100,
        width: 100,
        fit: fit,
        placeholderBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildRepoTile(Map repo) {
    return GestureDetector(
      onTap: () {
        launchUrl(
          Uri.parse(repo['url']),
          mode: LaunchMode.inAppWebView,
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.5),
            side: const BorderSide(width: 0.15)),
        margin: const EdgeInsets.all(0.5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            repo['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        // Fork button
                        IconButton(
                          onPressed: () => _showForkDialog(repo),
                          icon: const Icon(Icons.fork_right),
                          iconSize: 18,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(repo['owner'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    Text(
                      repo['description'] ?? '',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 2.w),
                        Text('${repo['stargazers_count'] ?? 0}'),
                        SizedBox(width: 15.w),
                        Icon(
                          Icons.fork_right,
                          size: 16.sp,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 2.w),
                        Text('${repo['forks_count'] ?? 0}'),
                        SizedBox(width: 15.w),
                        Icon(Icons.remove_red_eye_outlined,
                            size: 16.sp, color: AppColors.primaryColor),
                        SizedBox(width: 2.w),
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
              // Image section (existing code)
              GestureDetector(
                onTap: () {
                  debugPrint(repo['image_links'][0]);
                  (repo['image_links'] as List).length == 1
                      ? showDialog(
                          context: context,
                          builder: (_) => Dialog.fullscreen(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  InteractiveViewer(
                                      child: buildImageWidget(
                                          repo['image_links'][0],
                                          fit: BoxFit.contain)),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton.filledTonal(
                                        style: IconButton.styleFrom(
                                          side: const BorderSide(
                                              width: 1, color: Colors.grey),
                                          backgroundColor:
                                              Colors.black.withOpacity(0.6),
                                          foregroundColor:
                                              Colors.white.withOpacity(0.9),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.close_rounded)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : showDialog(
                          context: context,
                          builder: (_) => Dialog.fullscreen(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Text(
                                            '${(repo['image_links'] as List).length} Images'),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.all(5.0),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 5.0,
                                            crossAxisSpacing: 5.0,
                                          ),
                                          itemCount:
                                              (repo['image_links'] as List)
                                                  .length,
                                          itemBuilder: (context, index) {
                                            final image =
                                                repo['image_links'][index];
                                            return Card(
                                              child: GestureDetector(
                                                onTap: () {
                                                  debugPrint(image);
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        final scrollController =
                                                            ScrollController();
                                                        return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                          void
                                                              scrollToSelectedItem() {
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              if (scrollController
                                                                  .hasClients) {
                                                                const itemWidth =
                                                                    110.0;
                                                                final screenWidth =
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width;
                                                                final offset = (index *
                                                                        itemWidth) -
                                                                    (screenWidth /
                                                                        2) +
                                                                    (itemWidth /
                                                                        2);

                                                                final maxOffset =
                                                                    scrollController
                                                                        .position
                                                                        .maxScrollExtent;
                                                                final minOffset =
                                                                    scrollController
                                                                        .position
                                                                        .minScrollExtent;
                                                                final safeOffset =
                                                                    offset.clamp(
                                                                        minOffset,
                                                                        maxOffset);

                                                                scrollController
                                                                    .animateTo(
                                                                  safeOffset,
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  curve: Curves
                                                                      .easeInOut,
                                                                );
                                                              }
                                                            });
                                                          }

                                                          return Dialog(
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0),
                                                            ),
                                                            child: Stack(
                                                              fit: StackFit
                                                                  .expand,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          10,
                                                                          10,
                                                                          10,
                                                                          140),
                                                                  child:
                                                                      InteractiveViewer(
                                                                    child: buildImageWidget(
                                                                        repo['image_links']
                                                                            [
                                                                            index],
                                                                        fit: BoxFit
                                                                            .scaleDown),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10.0),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child: IconButton.filledTonal(
                                                                        style: IconButton.styleFrom(
                                                                          side: const BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey),
                                                                          backgroundColor: Colors
                                                                              .black
                                                                              .withOpacity(0.6),
                                                                          foregroundColor: Colors
                                                                              .white
                                                                              .withOpacity(0.9),
                                                                        ),
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        icon: const Icon(Icons.close_rounded)),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Visibility(
                                                                      maintainState:
                                                                          true,
                                                                      maintainAnimation:
                                                                          true,
                                                                      maintainSize:
                                                                          true,
                                                                      visible:
                                                                          index >
                                                                              0,
                                                                      child: IconButton
                                                                          .filledTonal(
                                                                        style: IconButton.styleFrom(
                                                                            side:
                                                                                const BorderSide(width: 1, color: Colors.grey),
                                                                            backgroundColor: Colors.white.withOpacity(0.75),
                                                                            padding: const EdgeInsets.all(0),
                                                                            minimumSize: const Size(0, 50)),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            index--;
                                                                            scrollToSelectedItem();
                                                                          });
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons.arrow_left_rounded),
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    Visibility(
                                                                      maintainState:
                                                                          true,
                                                                      maintainAnimation:
                                                                          true,
                                                                      maintainSize:
                                                                          true,
                                                                      visible: index <
                                                                          (repo['image_links'] as List).length -
                                                                              1,
                                                                      child: IconButton
                                                                          .filledTonal(
                                                                        style: IconButton.styleFrom(
                                                                            side:
                                                                                const BorderSide(width: 1, color: Colors.grey),
                                                                            backgroundColor: Colors.white.withOpacity(0.75),
                                                                            padding: const EdgeInsets.all(0),
                                                                            minimumSize: const Size(0, 50)),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            index++;
                                                                            scrollToSelectedItem();
                                                                          });
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons.arrow_right_rounded),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          120,
                                                                      child: ListView.builder(
                                                                          key: UniqueKey(),
                                                                          controller: scrollController,
                                                                          shrinkWrap: true,
                                                                          scrollDirection: Axis.horizontal,
                                                                          itemCount: (repo['image_links'] as List).length,
                                                                          itemBuilder: (context, index2) {
                                                                            bool
                                                                                isSelected =
                                                                                index2 == index;
                                                                            return Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    index = index2;
                                                                                    scrollToSelectedItem();
                                                                                  });
                                                                                },
                                                                                child: AnimatedContainer(
                                                                                  duration: const Duration(milliseconds: 300),
                                                                                  height: isSelected ? 120 : 100,
                                                                                  width: 100,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    border: Border.all(width: isSelected ? 5 : 1, color: Colors.grey),
                                                                                    image: DecorationImage(image: CachedNetworkImageProvider(repo['image_links'][index2]), fit: BoxFit.contain),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                      });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 0.25,
                                                        color: Colors.grey),
                                                  ),
                                                  child:
                                                      buildImageWidget(image),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            minimumSize: const Size(
                                                double.maxFinite, 15),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Close'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                },
                child: Stack(
                  children: [
                    Container(
                      width: 125,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 0.25, color: Colors.grey),
                      ),
                      child: (repo['image_links'] != null &&
                              (repo['image_links'] as List).isNotEmpty)
                          ? buildImageWidget(repo['image_links'][0])
                          : null,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
                        child: Container(
                          width: 125,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.25, color: Colors.grey),
                            color: (repo['image_links'] as List).length > 1
                                ? Colors.grey.shade200.withOpacity(0.0005)
                                : Colors.black.withOpacity(0.1),
                          ),
                          child: (repo['image_links'] as List).length > 1
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        color: Colors.grey.withOpacity(0.7)),
                                    child: Text(
                                      '${(repo['image_links'] as List).length}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              : (repo['image_links'] as List).isEmpty
                                  ? const Center(
                                      child: Text('No Images',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400)))
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Fork dialog - shows form to edit repo name for the new fork
  void _showForkDialog(Map repo) async {
    final TextEditingController nameController =
        TextEditingController(text: repo['name']);
    final TextEditingController descriptionController =
        TextEditingController(text: repo['description']);

    bool isEnable = true;
    bool isValidating = false;
    bool isNameAvailable = true;
    bool forkDefaultBranchOnly = true;
    bool hasInitialValidationRun = false; // Add this flag
    String? validationMessage;
    Timer? debounceTimer;

    // Get current user for validation
    String? currentUser;
    try {
      final token = await getAccessToken();
      currentUser = await GitOperations(token: token).getCurrentUser();
    } catch (e) {
      log('Failed to get current user: $e');
    }

    // Function to perform validation
    Future<void> validateName(String value, Function setState) async {
      // Cancel any existing timer
      debounceTimer?.cancel();

      if (value.isEmpty) {
        setState(() {
          isValidating = false;
          isNameAvailable = false;
          validationMessage = 'Repository name is required';
        });
        return;
      }

      // Basic client-side validation first
      if (value.contains(' ')) {
        setState(() {
          isValidating = false;
          isNameAvailable = false;
          validationMessage = 'Repository name cannot contain spaces';
        });
        return;
      }

      if (value.length < 3) {
        setState(() {
          isValidating = false;
          isNameAvailable = false;
          validationMessage = 'Repository name must be at least 3 characters';
        });
        return;
      }

      // Check for reserved names
      final reservedNames = ['admin', 'api', 'www', 'mail', 'ftp', 'root'];
      if (reservedNames.contains(value.toLowerCase())) {
        setState(() {
          isValidating = false;
          isNameAvailable = false;
          validationMessage = 'Repository name is reserved';
        });
        return;
      }

      // Set loading state
      setState(() {
        isValidating = true;
        validationMessage = null;
      });

      // Debounce API call
      debounceTimer = Timer(const Duration(milliseconds: 800), () async {
        try {
          if (currentUser != null) {
            final token = await getAccessToken();
            final result =
                await GitOperations(token: token).validateRepositoryName(
              owner: currentUser,
              repoName: value,
            );

            setState(() {
              isValidating = false;
              isNameAvailable = result['isAvailable'] ?? false;
              validationMessage =
                  result['isAvailable'] == true ? null : result['message'];
            });
          } else {
            setState(() {
              isValidating = false;
              isNameAvailable = false;
              validationMessage = 'Unable to validate name. Please try again.';
            });
          }
        } catch (e) {
          setState(() {
            isValidating = false;
            isNameAvailable = false;
            validationMessage = 'Failed to validate name. Please try again.';
          });
        }
      });
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            // Only run initial validation once
            if (!hasInitialValidationRun) {
              hasInitialValidationRun = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (nameController.text.isNotEmpty && currentUser != null) {
                  validateName(nameController.text, setState);
                }
              });
            }

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.fork_right, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text('Fork Repository'),
                ],
              ),
              content: SizedBox(
                width: ScreenUtil().screenWidth * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Forking "${repo['name']}" - Choose a name for your fork.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Repository Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter repository name for your fork',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: isValidating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : Icon(
                                isNameAvailable
                                    ? Icons.check_circle
                                    : Icons.error,
                                color:
                                    isNameAvailable ? Colors.green : Colors.red,
                              ),
                        errorText: validationMessage,
                      ),
                      onChanged: (value) => validateName(value, setState),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter description for your fork',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fork Options Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings,
                                  color: Colors.grey.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Fork Options',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: forkDefaultBranchOnly,
                                onChanged: (value) {
                                  setState(() {
                                    forkDefaultBranchOnly = value ?? true;
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Fork only the default branch',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Copy only the default branch. Creates a smaller, cleaner fork.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.fork_right,
                              color: Colors.orange.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              forkDefaultBranchOnly
                                  ? 'This will create a copy of the default branch in your account.'
                                  : 'This will create a copy of all branches in your account.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debounceTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: (!isValidating &&
                          isNameAvailable &&
                          nameController.text.isNotEmpty &&
                          isEnable)
                      ? () async {
                          debounceTimer?.cancel();
                          isEnable = await _handleFork(
                            repo,
                            nameController.text,
                            descriptionController.text,
                            forkDefaultBranchOnly,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.fork_right),
                  label: const Text('Create Fork'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

// Handle fork action
  Future<bool> _handleFork(Map repo, String newName, String newDescription,
      bool forkDefaultBranchOnly) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Forking "${repo['name']}" as "$newName"...'),
            ],
          ),
        ),
      );

      // Perform fork operation
      final token = await getAccessToken();
      await GitOperations(token: token).forkRepository(
        owner: repo['owner'],
        repo: repo['name'],
        newName: newName,
        newDescription: newDescription,
        defaultBranchOnly: forkDefaultBranchOnly,
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RepoListScreen(
              repoName: newName,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return true;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fork repository: $e')),
      );
    }
    return false;
  }

  String convertToRawGitHubUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://placehold.co/100x100?text=No+Image';
    }

    try {
      if (url.contains('github.com') && url.contains('/blob/')) {
        return url
            .replaceFirst('github.com', 'raw.githubusercontent.com')
            .replaceFirst('/blob/', '/');
      }
      return url;
    } catch (e) {
      debugPrint('Error converting URL: $e');
      return 'https://placehold.co/100x100?text=Error';
    }
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
                Badge.count(
                  offset: const Offset(0, 0),
                  count: activeFilterCount,
                  isLabelVisible: true,
                  child: IconButton(
                    onPressed: () {
                      _showFilterBottomSheet();
                    },
                    icon: const Icon(Icons.filter_alt),
                    color: Colors.white,
                  ),
                ),
              ],
              title: SearchBar(
                autoFocus: false,
                controller: _searchController,
                hintText: 'Search for repositories',
                onSubmitted: (value) => _performSearch(value),
                onChanged: (value) async {
                  QuerySnapshot querySnapshot = await _firestore
                      .collection('Repositories')
                      .where('name', isGreaterThanOrEqualTo: value)
                      .where('name', isLessThan: '$value\uF7FF')
                      .get();
                  setState(() {
                    for (var repo in querySnapshot.docs) {
                      if (!_repos.contains(repo)) {
                        _repos.add(repo);
                      }
                    }
                  });
                },
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
                            _getRepos();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear)),
                ],
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        body: _searchController.text.isEmpty
            ? activeFilterCount > 0
                ? FutureBuilder<List<DocumentSnapshot>>(
                    future: getFilteredRepos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final filteredRepos = snapshot.data ?? [];
                      if (filteredRepos.isEmpty) {
                        return const Center(
                            child: Text('No matching repositories found'));
                      }

                      return ListView.builder(
                        itemCount: filteredRepos.length,
                        itemBuilder: (context, index) {
                          final repo = filteredRepos[index].data()
                              as Map<String, dynamic>;
                          return Padding(
                              padding: const EdgeInsets.all(5),
                              child: _buildRepoTile(repo));
                        },
                      );
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _repos.length,
                    itemBuilder: (context, index) {
                      final repo = _repos[index].data() as Map<String, dynamic>;

                      return Padding(
                          padding: const EdgeInsets.all(5),
                          child: _buildRepoTile(repo));
                    },
                  )
            : StreamBuilder(
                stream: _firestore
                    .collection('Repositories')
                    .where('name',
                        isGreaterThanOrEqualTo: _searchController.text)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final filteredRepos = docs;
                  if (filteredRepos.isEmpty) {
                    return const Center(
                      child: Text(
                        'No repositories found',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredRepos.length,
                    itemBuilder: (context, index) {
                      final repo = filteredRepos[index].data();

                      return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _buildRepoTile(repo));
                    },
                  );
                },
              ));
  }
}
