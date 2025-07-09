import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_builder_app/views/markdown_editor_screen.dart';

import '../data/git_operations.dart';
import '../models/git_repo_model.dart';
import '../models/repo_content_model.dart';

class RepoContentScreen extends ConsumerStatefulWidget {
  const RepoContentScreen(
      {super.key, required this.repo, required this.ops, required this.path});

  final GitRepo repo;
  final GitOperations ops;
  final String path;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RepoContentScreenState();
}

class _RepoContentScreenState extends ConsumerState<RepoContentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.repo.name),
      ),
      body: FutureBuilder(
        future: widget.ops.getRepoContents(
            widget.repo.owner.login, widget.repo.name, widget.path),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final content = RepoContent.fromMap(data.elementAt(index));

                var isDir = content.type.toLowerCase() == 'dir';

                return Card(
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(isDir ? Icons.folder : Icons.text_snippet),
                    title: Text(content.name),
                    trailing: content.name.endsWith(".md")
                        ? TextButton(
                            style: TextButton.styleFrom(
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                  side: BorderSide(
                                      width: 0.5, color: Colors.white)),
                            ),
                            onPressed: () async {
                              final fileData = await widget.ops.getRepoContents(
                                  widget.repo.owner.login,
                                  widget.repo.name,
                                  content.path);
                              //log(fileData.toString());
                              final fileContent = base64Decode(
                                  fileData['content']
                                      .replaceAll('\n', '')
                                      .replaceAll('\r', ''));
                              final initialText = utf8.decode(fileContent);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MarkdownEditorScreen(
                                            initialText: initialText,
                                            fileName: content.name,
                                            ops: widget.ops,
                                            repo: widget.repo,
                                            path: content.path,
                                          )));
                            },
                            child: Text("Edit"))
                        : null,
                    onTap: isDir
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RepoContentScreen(
                                        repo: widget.repo,
                                        ops: widget.ops,
                                        path: content.path)));
                          }
                        : null,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error occurred/ No files found'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              children: [
                AddFileDialogContent(ops: widget.ops, repo: widget.repo),
              ],
            ),
          );

          setState(() {});
        },
        label: const Text('Upload a File'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class AddFileDialogContent extends StatefulWidget {
  const AddFileDialogContent(
      {super.key, required this.ops, required this.repo});

  final GitOperations ops;
  final GitRepo repo;

  @override
  State<AddFileDialogContent> createState() => _AddFileDialogContentState();
}

class _AddFileDialogContentState extends State<AddFileDialogContent> {
  final commitMessageC = TextEditingController();
  File? file;
  String? fileName;

  final GlobalKey _formKey = GlobalKey<FormState>();
  Map<String, File> files = {}; // Map to store multiple files

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Upload Files:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 0,
              child: Row(
                children: [
                  const Text(' Files: '),
                  TextButton(
                    child: Text(fileName ?? 'Tap to pick (Max 100 MB)'),
                    onPressed: () async {
                      const XTypeGroup typeGroup = XTypeGroup(
                        extensions: <String>[
                          'pdf',
                          'png',
                          'jpg',
                          'txt',
                          'dart',
                          'yaml',
                          'lock',
                          'gitignore',
                          'md',
                          'metadata',
                        ],
                      );

                      final List<XFile>? pickedFiles = await openFiles(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup],
                      );

                      if (pickedFiles != null && pickedFiles.isNotEmpty) {
                        files.clear(); // Clear previous selections
                        for (XFile pickedFile in pickedFiles) {
                          files[pickedFile.name] = File(pickedFile.path);
                        }
                        // file = File(pickedFile.path);
                        // fileName = pickedFile.name;

                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: TextFormField(
                controller: commitMessageC,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: ' Commit Message: ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            Wrap(children: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.secondaryContainer)),
                onPressed: () async {
                  if ((_formKey.currentState! as FormState).validate()) {
                    if (files.isNotEmpty) {
                      try {
                        if (files.length == 1) {
                          await widget.ops
                              .addFileToRepo(
                                  widget.repo.owner.login,
                                  widget.repo.name,
                                  files,
                                  // fileName!,
                                  // file!,
                                  commitMessageC.text)
                              .then((_) {
                            if (context.mounted) {
                              context.pop();
                            }
                          });
                        } else {
                          await widget.ops
                              .commitMultipleFiles(
                            owner: widget.repo.owner.login,
                            repo: widget.repo.name,
                            branch: 'main',
                            files: files,
                            commitMessage: commitMessageC.text,
                          )
                              .then((_) {
                            if (context.mounted) {
                              context.pop();
                            }
                          });
                        }
                      } on Exception catch (e) {
                        log(e.toString());
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please pick a file')));
                    }
                  }
                },
                child: const Text('Upload'),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
