import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/models/git_repo_model.dart';
import 'package:resume_builder_app/views/widgets/MarkDownTextInput/markdown_text_input.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

class MarkdownEditorScreen extends StatefulWidget {
  final String initialText;
  final String path;
  final String fileName;
  GitRepo repo;
  GitOperations ops;

  MarkdownEditorScreen({
    required this.initialText,
    required this.ops,
    required this.repo,
    required this.path,
    required this.fileName,
  });

  @override
  _MarkdownEditorScreenState createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  late TextEditingController _controller;
  bool _isVerticalView = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_updatePreview);
  }

  Future<void> showCommitDialog(BuildContext context, dynamic newContent) async {
    final commitMsg = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Commit Message"),
          content: SingleChildScrollView(
            child: Center(
              child: TextField(
                maxLines: 5,
                controller: commitMsg,
                decoration: InputDecoration(
                  label: Text("Enter Message"),
                  constraints: BoxConstraints(maxHeight: 200),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await widget.ops.updateFileInRepo(
                    widget.repo.owner.login,
                    widget.repo.name,
                    widget.path,
                    newContent,
                    commitMsg.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Committed Successfully...")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to Commit")),
                  );
                }
                Navigator.pop(context);
              },
              child: Text("Commit"),
            ),
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
              textStyle: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final content = _controller.text;
              await showCommitDialog(context, content);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(_isVerticalView ? Icons.swap_vert : Icons.swap_horiz),
            onPressed: () {
              setState(() {
                _isVerticalView = !_isVerticalView;
              });
            },
          ),
        ],
      ),
      body: _isVerticalView ? buildVerticalView() : buildHorizontalView(),
    );
  }

  Widget buildVerticalView() {
    return Column(
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
          child: markdownPreviewWidget(),
        ),
      ],
    );
  }

  Widget buildHorizontalView() {
    return Row(
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
          child: markdownPreviewWidget(),
        ),
      ],
    );
  }

  Widget markdownPreviewWidget() {
    return Card(
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Scrollbar(
          interactive: true,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: HtmlMarkdownBody(data: _controller.text),
          ),
        ),
      ),
    );
  }
}

class HtmlMarkdownBody extends StatelessWidget {
  final String data;

  HtmlMarkdownBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final document = html_parser.parse(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: document.body!.nodes.map((node) {
        if (node is dom.Element && node.localName == 'img') {
          final src = node.attributes['src'];
          final width = node.attributes['width'];
          final height = node.attributes['height'];
          return Image.network(
            src!,
            width: width != null ? double.tryParse(width) : null,
            height: height != null ? double.tryParse(height) : null,
          );
        } else if (node is dom.Element) {
          // Handle other HTML elements if needed
          return MarkdownBody(
            data: node.text ?? '',
            onTapLink: (i, j, k) {
              if (j != null) {
                launchUrl(Uri.parse(j));
              }
            },
            imageBuilder: (uri, title, alt) {
              return Image.network(
                uri.toString(),
                errorBuilder: (_, __, ___) {
                  return Text(alt ?? 'Error loading image');
                },
              );
            },
          );
        } else {
          // Handle text nodes
          return MarkdownBody(
            data: node.text ?? '',
            onTapLink: (i, j, k) {
              if (j != null) {
                launchUrl(Uri.parse(j));
              }
            },
            imageBuilder: (uri, title, alt) {
              return Image.network(
                uri.toString(),
                errorBuilder: (_, __, ___) {
                  return Text(alt ?? 'Error loading image');
                },
              );
            },
          );
        }
      }).toList(),
    );
  }
}
