import 'package:flutter/material.dart';
import 'package:resume_builder_app/views/jobs/ui/screens/repoListScreen.dart';
import '../../../../models/jobs_model.dart';

class DetailsScreen extends StatefulWidget {
  final Job job;

  const DetailsScreen({super.key, required this.job});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List<Map<String, String>> allRepo = [];
  Set<String> allCompanies = {};
  String? selectedCompany = null; // Default to an empty string instead of null


  // Loop through each company and its repositories
  void allRepository() {
    for (var company in widget.job.companies) {
      allCompanies.add(company.name);
      for (var repo in company.repositories) {
        allRepo.add({
          'companyName': company.name,
          'owner': repo.owner,
          'repo': repo.repo,
        });
      }
    }
    print(allRepo);
  }

  @override
  void initState() {
    super.initState();
    allRepository();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 2,
              child: Image.network(
                "https://cdn.pixabay.com/photo/2015/01/08/18/26/write-593333_960_720.jpg",
                fit: BoxFit.cover,
                color: Colors.black38,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.file_upload,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height / 2,
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${widget.job.title}",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        "${widget.job.location}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Overview",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "${widget.job.description}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Photos",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.job.companies.length,
                          itemBuilder: (ctx, i) {
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 9.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                    "https://www.citypng.com/public/uploads/preview/pubg-gold-silhouette-soldier-with-helmet-logo-733961695143139ogipqdztwz.png"
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.height * .7,
                        height: 45,
                        child: ElevatedButton(
                          child: Text(
                            "Apply For Job",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.apply(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      width: double.maxFinite,
                                      height: 500,
                                      child: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setDialogState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Work Available",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    DropdownButton<String>(
                                                      value: selectedCompany,
                                                      hint: Text('Company'),
                                                      onChanged: (String? newValue) {
                                                        setState(() {
                                                          selectedCompany = newValue;
                                                        });
                                                        setDialogState(() {}); // Update dialog's state
                                                      },
                                                      items: allCompanies.map<DropdownMenuItem<String>>((String value) {
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: TextStyle(
                                                              color: value == selectedCompany ? Colors.blue : Colors.black,
                                                              fontWeight: value == selectedCompany ? FontWeight.bold : FontWeight.normal,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(),
                                              Expanded(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: allRepo.length,
                                                  itemBuilder: (context, index) {
                                                    if (selectedCompany != null &&
                                                        selectedCompany!.isNotEmpty &&
                                                        allRepo[index]["companyName"] == selectedCompany) {
                                                      return InkWell(
                                                        child: ListTile(
                                                          title: Text(
                                                            "Owner: ${allRepo[index]['owner']}",
                                                            style: TextStyle(fontWeight: FontWeight.w600),
                                                          ),
                                                          subtitle: Text(
                                                            "Repo: ${allRepo[index]["repo"]}",
                                                          ),
                                                        ),
                                                        onTap: ()=> Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (ctx) => repoListScreen(owner:allRepo[index]["owner"]! , repo:allRepo[index]["repo"]!),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return SizedBox.shrink(); // Hide items that don’t match
                                                    }
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Close"),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
