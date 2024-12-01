import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/models/git_repo_model.dart';
import 'package:resume_builder_app/views/widgets/MarkDownTextInput/markdown_text_input.dart';
import 'dart:convert';

class MarkdownEditorScreen extends StatefulWidget {
  final String initialText;
  final String path;
  final String fileName;
  GitRepo repo;
  GitOperations ops;

  MarkdownEditorScreen(
      {required this.initialText,
      required this.ops,
      required this.repo,
      required this.path,
      required this.fileName});

  @override
  _MarkdownEditorScreenState createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_updatePreview);
  }

  Future<void> showCommitDialog(BuildContext context,dynamic newContent)async{
    final commitMsg=TextEditingController();
    return showDialog(context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text("Commit Message"),
          content: SingleChildScrollView(
            child: Center(
              child: TextField(
                //expands: true,
                maxLines: 5,
                controller: commitMsg,
                decoration: InputDecoration(
                    label: Text("Enter Message"),
                    constraints: BoxConstraints(
                        maxHeight: 200
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1)
                    )
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: (){
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Commit")));
              Navigator.pop(context);
            }, child: Text("Cancel")),
            TextButton(
                onPressed: () async {
                  try {
                    await widget.ops.updateFileInRepo(
                        widget.repo.owner.login,
                        widget.repo.name,
                        widget.path,
                        newContent,
                        commitMsg.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Commited Successfully...")));
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to Commit")));
                  }
                  Navigator.pop(context);
                },
                child: Text("Commit")),

          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePreview);
    _controller.dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.fileName}'),
        actions: [
          ElevatedButton(
            child: Text("Commit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              textStyle: TextStyle(color: Colors.white)
            ),
            onPressed: () async{
              final content = _controller.text;
              await showCommitDialog(context,content);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MarkdownTextInput(
                  (String value) {},
              widget.initialText,
              controller: _controller,
              label: 'Markdown Editor',
            ),
          ),
          Expanded(
            child: Markdown(
              data: _controller.text,
            ),
          ),
        ],
      ),
    );
  }
}

