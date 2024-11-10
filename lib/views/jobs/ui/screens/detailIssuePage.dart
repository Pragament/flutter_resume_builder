import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:resume_builder_app/views/jobs/models/jobissue_model.dart';
import 'package:http/http.dart' as http;

class DetailIssueScreen extends StatefulWidget {
  final GitHubIssue issue;
  const DetailIssueScreen({super.key, required this.issue});

  @override
  State<DetailIssueScreen> createState() => _DetailIssueScreenState();
}

class _DetailIssueScreenState extends State<DetailIssueScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  Future<void> postComment(String comment, String YOUR_PERSONAL_ACCESS_TOKEN) async {
    final response = await http.post(
      Uri.parse(widget.issue.comments_url),
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': '$YOUR_PERSONAL_ACCESS_TOKEN',  // Add token here
      },
      body: json.encode({'body': comment}),
    );

    if (response.statusCode == 201) {
      setState(() {
        _commentController.clear();
        _tokenController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment posted successfully!')),
      );
    } else {
      print('Error: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Issue"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
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
                    decoration: BoxDecoration(
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
                          "${widget.issue.title}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "${widget.issue.id}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.apply(color: Colors.grey),
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          "Description",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 10),
                        MarkdownBody(
                          data: widget.issue.body, // Render body as Markdown
                          styleSheet: MarkdownStyleSheet(
                            p: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.apply(color: Colors.black87),
                          ),
                        ),
                        SizedBox(height: 15.0),
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
              child: Container(
                width: MediaQuery.of(context).size.height * .7,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              height: 350,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(left: 100,top: 20,),
                                      child: Text("Your Comment",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)
                                      )),
                                  SizedBox(height: 20),
                                 Padding(
                                   padding: const EdgeInsets.only(left:20,),
                                   child:  Text("Your Github Token (clickMe?)",style: TextStyle(
                                       fontSize: 15,
                                       fontWeight: FontWeight.w700)
                                   ),
                                 ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: TextField(
                                      controller: _tokenController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Github Token' ,

                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.only(left:16,),
                                    child:  Text("Add Comment",style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: TextField(
                                      controller: _commentController,
                                      decoration: InputDecoration(
                                          hintText: 'Your comment'),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Center(

                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_commentController.text.isNotEmpty &&
                                            _tokenController.text.isNotEmpty) {
                                          setState(() {
                                            postComment(_commentController.text,
                                                _tokenController.text);
                                          });
                                        }
                                        else{
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Enter The Comment And Github Token')),
                                          );
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text('Post Comment'),
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
