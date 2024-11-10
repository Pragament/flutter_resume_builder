import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resume_builder_app/views/jobs/models/jobissue_model.dart';
import 'package:http/http.dart' as http;
import 'package:resume_builder_app/views/jobs/ui/screens/detailIssuePage.dart';
import 'package:resume_builder_app/views/jobs/ui/widgets/issueContainer.dart';
class repoListScreen extends StatefulWidget {
  final String owner;
  final String repo;
  const repoListScreen({
  super.key,
   required this.owner,
    required this.repo
  });


  @override
  State<repoListScreen> createState() => _repoListScreenState();
}

class _repoListScreenState extends State<repoListScreen> {

  List<GitHubIssue> allIssue = [];
    void fetchOpenUnassignedIssues() async {
      String githubUrl ='https://api.github.com/repos/${widget.owner}/${widget.repo}/issues?state=open&assignee=none';
      final response = await http.get(Uri.parse(githubUrl));
      if (response.statusCode == 200) {
        List<dynamic> issuesJson = json.decode(response.body);
     allIssue= issuesJson.map(
             (issue) => GitHubIssue.fromJson(issue)
     ).toList();

      setState(() {
        print(allIssue);
      });
      } else {
        throw Exception('Failed to load issues');
      }
    }


  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    fetchOpenUnassignedIssues();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Issues", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body:Column(
        children:[
      Expanded( // Use Expanded here to make ListView take available space
      child: ListView.builder(
      itemCount: allIssue.length,
        itemBuilder: (ctx, i) {
          return SizedBox(
            height: 190, // Adjust height if needed
            child: issueContainer(
              issue: allIssue[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => DetailIssueScreen(issue: allIssue[i],),
                ),
              ),
            ),
          );
        },
      ),
    ),
    ],
      ),
    );
  }
}
