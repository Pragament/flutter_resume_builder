import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:resume_builder_app/shared_preferences.dart';
import 'package:resume_builder_app/views/jobs/models/jobissue_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailIssueScreen extends StatefulWidget {
  final GitHubIssue issue;
  const DetailIssueScreen({super.key, required this.issue});

  @override
  State<DetailIssueScreen> createState() => _DetailIssueScreenState();
}

class _DetailIssueScreenState extends State<DetailIssueScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  Future<void> postComment(String comment) async {
    String? acessToken= await getAccessToken();
    print("token is $acessToken");
    final response = await http.post(
      Uri.parse(widget.issue.comments_url),
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer $acessToken',  // Add token here
      },
      body: json.encode({'body': comment}),
    );

    if (response.statusCode == 201) {
      setState(() {
        _commentController.clear();
        _tokenController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully!')),
      );
    } else {
      print('Error: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Detail Issue"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      "https://cdn.pixabay.com/photo/2014/07/15/23/36/github-394322_1280.png",
                      fit: BoxFit.fitWidth,
                      color: Colors.black38,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.issue.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "${widget.issue.id}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.apply(color: Colors.grey),
                        ),
                        const SizedBox(height: 15.0),
                        Text(
                          "Description",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        MarkdownBody(
                          data: widget.issue.body, // Render body as Markdown
                          styleSheet: MarkdownStyleSheet(
                            p: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.apply(color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: SizedBox(
                width: MediaQuery.of(context).size.height * .7,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: SizedBox(
                              height: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                      padding: EdgeInsets.only(left: 100,top: 20,),
                                      child: Text("Your Comment",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)
                                      )),
                                  const SizedBox(height: 15),
                                  const Padding(
                                    padding: EdgeInsets.only(left:16,),
                                    child:  Text("Add Comment",style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0,top: 10),
                                    child: TextField(
                                      controller: _commentController,
                                      decoration: const InputDecoration(
                                          hintText: 'Your comment'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Center(

                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_commentController.text.isNotEmpty) {
                                          setState(() {
                                            postComment(_commentController.text);
                                          });
                                        }
                                        else{
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Enter The Comment And Github Token')),
                                          );
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Post Comment'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    "Comment for Job",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.apply(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
