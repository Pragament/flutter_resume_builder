import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'format_markdown.dart';
import 'package:resume_builder_app/data/git_operations.dart';
import 'package:resume_builder_app/models/git_repo_model.dart';

class MarkdownTextInput extends StatefulWidget {
  final Function onTextChanged;
  final String initialValue;
  final String? Function(String? value)? validators;
  final String? label;
  final TextDirection textDirection;
  final int? maxLines;
  final List<MarkdownType> actions;
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final bool insertLinksByDialog;
  GitRepo repo;
  GitOperations ops;

  MarkdownTextInput(
      this.onTextChanged,
      this.initialValue, {
        super.key,
        this.label = '',
        this.validators,
        this.textDirection = TextDirection.ltr,
        this.maxLines,
        this.actions = const [
          MarkdownType.bold,
          MarkdownType.italic,
          MarkdownType.title,
          MarkdownType.link,
          MarkdownType.list,
          MarkdownType.strikethrough,
          MarkdownType.code,
          MarkdownType.blockquote,
          MarkdownType.separator,
          MarkdownType.image
        ],
        this.textStyle,
        this.controller,
        this.insertLinksByDialog = true,
        required this.ops,
        required this.repo,
      });

  @override
  State<MarkdownTextInput> createState() => _MarkdownTextInputState();
}

class _MarkdownTextInputState extends State<MarkdownTextInput> {
  late final TextEditingController _controller;
  TextSelection textSelection =
  const TextSelection(baseOffset: 0, extentOffset: 0);
  FocusNode focusNode = FocusNode();

  void onTap(MarkdownType type,
      {int titleSize = 1, String? link, String? selectedText}) {
    final basePosition = textSelection.baseOffset;
    var noTextSelected =
        (textSelection.baseOffset - textSelection.extentOffset) == 0;

    var fromIndex = textSelection.baseOffset;
    var toIndex = textSelection.extentOffset;

    final result = FormatMarkdown.convertToMarkdown(
        type, _controller.text, fromIndex, toIndex,
        titleSize: titleSize,
        link: link,
        selectedText:
        selectedText ?? _controller.text.substring(fromIndex, toIndex));

    _controller.value = _controller.value.copyWith(
        text: result.data,
        selection:
        TextSelection.collapsed(offset: basePosition + result.cursorIndex));

    if (noTextSelected) {
      _controller.selection = TextSelection.collapsed(
          offset: _controller.selection.end - result.replaceCursorIndex);
      focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _controller.text = widget.initialValue;
    _controller.addListener(() {
      if (_controller.selection.baseOffset != -1) {
        textSelection = _controller.selection;
      }
      widget.onTextChanged(_controller.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Widget _basicInkwell(MarkdownType type, {Function? customOnTap}) {
    return InkWell(
      key: Key(type.key),
      onTap: () => customOnTap != null ? customOnTap() : onTap(type),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(type.icon),
      ),
    );
  }

  Widget actionWidget(MarkdownType type) {
    switch (type) {
      case MarkdownType.title:
        return ExpandableNotifier(
          child: Expandable(
            key: const Key('H#_button'),
            collapsed: ExpandableButton(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'H#',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            expanded: Container(
              color: Colors.white10,
              child: Row(
                children: [
                  for (int i = 1; i <= 6; i++)
                    InkWell(
                      key: Key('H${i}_button'),
                      onTap: () => onTap(MarkdownType.title, titleSize: i),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'H$i',
                          style: TextStyle(
                              fontSize: (18 - i).toDouble(),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ExpandableButton(
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case MarkdownType.link:
        return _basicInkwell(
          type,
          customOnTap: !widget.insertLinksByDialog
              ? null
              : () async {
            var text = _controller.text.substring(
                textSelection.baseOffset, textSelection.extentOffset);

            var textController = TextEditingController()..text = text;
            var linkController = TextEditingController();
            var textFocus = FocusNode();
            var linkFocus = FocusNode();

            var color = Theme.of(context).colorScheme.secondary;

            await showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () => Navigator.pop(context))
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'example',
                          label: Text(
                              'AppLocalizations.of(context)!.linkDialogTextTitle'),
                          labelStyle: TextStyle(color: color),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: color, width: 2)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: color, width: 2)),
                        ),
                        autofocus: text.isEmpty,
                        focusNode: textFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          textFocus.unfocus();
                          FocusScope.of(context).requestFocus(linkFocus);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: linkController,
                        decoration: InputDecoration(
                          hintText: 'https://www.example.com',
                          label: Text(
                              'AppLocalizations.of(context)!.linkDialogLinkTitle'),
                          labelStyle: TextStyle(color: color),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: color, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: color, width: 2),
                          ),
                        ),
                        autofocus: text.isNotEmpty,
                        focusNode: linkFocus,
                      ),
                    ],
                  ),
                  contentPadding:
                  const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
                  actions: [
                    TextButton(
                      onPressed: () {
                        onTap(type,
                            link: linkController.text,
                            selectedText: textController.text);
                        Navigator.pop(context);
                      },
                      child: Text('AppLocalizations.of(context)!.ok'),
                    ),
                  ],
                );
              },
            );
          },
        );

      case MarkdownType.image:
        return _basicInkwell(
          type,
          customOnTap: () async {
            List<String> imageUrls = [];
            //print("getting urls" + widget.repo.owner.login.toString());
            try {
              imageUrls = await widget.ops
                  .fetchGitHubImages(widget.repo.owner.login, widget.repo.name);

              //imageUrls = await GitOperations.fetchGitHubImages();
            } catch (e) {
              print("Error fetching images: $e");
            }

            if (imageUrls.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No images found in the repository.")),
              );
              return;
            }

            await showDialog<void>(
              context: context,
              builder: (context) {
                Set<int> selectedImageIndexes =
                {}; // Stores selected image indexes

                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text("Select Images"),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 500, // Adjust height if needed
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  bool isSelected =
                                  selectedImageIndexes.contains(index);
                                  String imageName = imageUrls[index]
                                      .split('/')
                                      .last; // Extract filename

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedImageIndexes.remove(index);
                                        } else {
                                          selectedImageIndexes.add(index);
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.network(imageUrls[index],
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover),
                                            if (isSelected)
                                              Container(
                                                height: 80,
                                                width: 80,
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                child: Icon(Icons.check,
                                                    color: Colors.white,
                                                    size: 40),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(imageName,
                                            style: TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: selectedImageIndexes.isNotEmpty
                                  ? () {
                                List<String> selectedImagesMarkdown =
                                selectedImageIndexes.map((index) {
                                  String url = imageUrls[index];
                                  String imageName = url.split('/').last;
                                  return "![${imageName}](${url})"; // Markdown format
                                }).toList();

                                String markdownText =
                                selectedImagesMarkdown.join(
                                    "\n"); // Join all selected images

                                onTap(
                                  type,
                                  selectedText:
                                  markdownText, // Markdown content
                                  link: selectedImagesMarkdown
                                      .join(", "), // Just in case
                                );

                                //print(markdownText);
                                _controller.text += "\n" + markdownText;
                                Navigator.pop(context, markdownText);
                              }
                                  : null, // Disable button if no images are selected
                              child: Text("Choose Selected"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );

      default:
        return _basicInkwell(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                widget.actions.map((type) => actionWidget(type)).toList(),
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: SingleChildScrollView(
              child: TextFormField(
                focusNode: focusNode,
                textInputAction: TextInputAction.newline,
                maxLines: widget.maxLines,
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                validator: widget.validators != null
                    ? (value) => widget.validators!(value)
                    : null,
                style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,
                cursorColor: Theme.of(context).colorScheme.primary,
                textDirection: widget.textDirection,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  hintText: widget.label,
                  hintStyle:
                  const TextStyle(color: Color.fromRGBO(63, 61, 86, 0.5)),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
