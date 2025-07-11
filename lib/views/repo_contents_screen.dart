import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_builder_app/views/markdown_editor_screen.dart';
import 'package:resume_builder_app/views/add_file_dialog_content.dart';
import 'package:yaml/yaml.dart';
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
                              shape: const BeveledRectangleBorder(
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
                            child: const Text("Edit"))
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
          // Fetch media_folder from config before opening dialog
          String mediaFolder = '';
          try {
            bool configExists = await widget.ops.repoFileExists(
              'admin/config.yml',
              owner: widget.repo.owner.login,
              repo: widget.repo.name,
            );
            if (configExists) {
              String decodedConfig = await widget.ops.readRepoFile(
                'admin/config.yml',
                owner: widget.repo.owner.login,
                repo: widget.repo.name,
              );
              var yamlMap = loadYaml(decodedConfig);
              mediaFolder = yamlMap['media_folder'] ?? '';
            }
          } catch (e) {
            // ignore, fallback to root
          }
          await showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              children: [
                AddFileDialogContent(ops: widget.ops, repo: widget.repo, mediaFolder: mediaFolder),
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
