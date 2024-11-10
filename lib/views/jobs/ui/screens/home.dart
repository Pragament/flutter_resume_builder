import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_builder_app/views/jobs/ui/job_filter_provider.dart';
import '../../../../models/bottomsheetmodel.dart';
import '../job_provider.dart';
import '../widgets/jobcontainer.dart';
import '../widgets/mybottomsheet.dart';
import 'details.dart';
class JobScreen extends ConsumerWidget {
  // Create a TextEditingController for the search field
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger job fetching when widget is built
    ref.read(jobProvider.notifier).fetchJobs();
    final jobList = ref.watch(jobProvider);
    final isBottomSheetVisible = ref.watch(myBottomSheetProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xfff0f0f6),
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 7.0),
                    const SizedBox(height: 15),
                    Container(
                      height: 51,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: const Color(0xffe6e6ec),
                                filled: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                              onPressed: (){
                                //update the
                                ref.read(jobFilterProvider.notifier).updateSearch(_searchController.text);
                                ref.read(jobProvider.notifier).fetchJobs();
                              },
                              child:Icon(Icons.search)
                          ),
                          const SizedBox(width: 15),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffe6e6ec),
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.tune),
                              onPressed: () {
                                ref.read(myBottomSheetProvider.notifier).changeState();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Expanded(
                      child: jobList.isEmpty
                          ? Center(child: Text("No jobs found"))
                          : ListView.builder(
                        itemCount: jobList.length,
                        itemBuilder: (ctx, i) {
                          return JobContainer(
                            description: jobList[i].description,
                            location: jobList[i].location,
                            minSalary: jobList[i].salary.min.toString(),
                            maxSalary: jobList[i].salary.max.toString(),
                            title: jobList[i].title,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => DetailsScreen(job: jobList[i]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isBottomSheetVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height / 1.3,
                child: MyBottomSheet(),
              ),
          ],
        ),
      ),
    );
  }
}
