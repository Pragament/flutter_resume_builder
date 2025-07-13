import 'dart:developer';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/git_operations.dart';
import '../models/git_repo_model.dart';

class AddFileDialogContent extends StatefulWidget {
  const AddFileDialogContent({super.key, required this.ops, required this.repo, required this.mediaFolder});

  final GitOperations ops;
  final GitRepo repo;
  final String mediaFolder;

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
            if (files.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Files:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: files.keys.map((fileName) {
                        return Chip(
                          label: Text(fileName),
                          onDeleted: () {
                            setState(() {
                              files.remove(fileName);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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

                      final List<XFile> pickedFiles = await openFiles(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup],
                      );

                      if (pickedFiles != null && pickedFiles.isNotEmpty) {
                        files.clear(); // Clear previous selections
                        for (XFile pickedFile in pickedFiles) {
                          final String prefixedName = widget.mediaFolder.isNotEmpty
                              ? '${widget.mediaFolder}/${pickedFile.name}'
                              : pickedFile.name;
                          files[prefixedName] = File(pickedFile.path);
                        }
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