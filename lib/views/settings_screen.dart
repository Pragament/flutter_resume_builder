import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';

import '../models/settings_model.dart';
import '../providers/settings_provider.dart';
import 'widgets/custom_slider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar().build(context, 'Settings'),
        body: const CompressionSettingsCard());
  }
}

class CompressionSettingsCard extends StatelessWidget {
  const CompressionSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.blue.shade200,
      title: const Text(
        "Compression Settings (optional)",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Consumer(builder: (context, ref, child) {
          final settings = ref.watch(settingsProvider);

          return Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Radio<CompressionOption>(
                          value: CompressionOption.maxFileSize,
                          groupValue: settings.selectedOption,
                          onChanged: (CompressionOption? value) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateSelectedOption(value!);
                          },
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateSelectedOption(
                                          CompressionOption.maxFileSize);
                                },
                                child: const Text(
                                  "Max File Size (KB)",
                                  style: TextStyle(
                                    letterSpacing: -0.3,
                                    wordSpacing: -0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tooltip(
                                message:
                                    "Set a maximum file size for compression.",
                                child: Icon(
                                  Icons.help_outline,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<CompressionOption>(
                          value: CompressionOption.quality,
                          groupValue: settings.selectedOption,
                          onChanged: (CompressionOption? value) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateSelectedOption(value!);
                          },
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateSelectedOption(
                                          CompressionOption.quality);
                                },
                                child: const Text(
                                  "Quality",
                                  style: TextStyle(
                                    letterSpacing: -0.3,
                                    wordSpacing: -0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: "Set image quality percentage.",
                                child: Icon(
                                  Icons.help_outline,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              settings.selectedOption == CompressionOption.maxFileSize
                  ? Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: TextFormField(
                          initialValue: ref
                              .read(settingsProvider)
                              .maxFileSize?.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateMaxFileSize(double.tryParse(value));
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide:
                                  const BorderSide(color: Colors.grey),
                            ),
                            hintText: 'Enter Max File Size',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Expanded(
                      flex: 5,
                      child: CustomSlider(),
                    ),
            ],
          );
        }),
      ],
    );
  }
}
