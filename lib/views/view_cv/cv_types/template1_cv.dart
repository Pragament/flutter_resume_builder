
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';

import 'classic_cv.dart';

class ResumeScreen3 extends StatelessWidget {

  final TemplateData templateData;
  final List<HighlightedProject> highlightedProjects;
  // final UserDetails userDetails;
  const ResumeScreen3({super.key, required this.templateData, required this.highlightedProjects});

  Future<void> _generateAndPrintResume(BuildContext context) async {
    final pdfData = await generateResume(PdfPageFormat.a4, templateData);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    // Hardcoded list of projects

    return Scaffold(
      floatingActionButton: _buildSaveSection(
          templateData, () => _generateAndPrintResume(context)),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Top Portion
                Row(
                  children: [
                    // Image and details
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: AppColors.primaryColor,
                            backgroundImage: templateData.image != null
                                ? FileImage(File(templateData.image!))
                                : null,
                            child: templateData.image == null
                                ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            templateData.currentPosition ?? "",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            templateData.email ?? "",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900]
                            ),

                          ),
                          Text(
                            templateData.phoneNumber ?? "",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Name and profile
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            templateData.fullName,
                            style: TextStyle(
                                fontSize: 27, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF06a2d8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  templateData.bio ?? "",
                                  style: TextStyle(fontSize: 10),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: w * 0.87,
                  color: Colors.grey,
                  height: 2,
                ),
                const SizedBox(height: 10),
                // Projects Section
                Row(
                  children: [
                    // Projects & Experience Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (highlightedProjects.isNotEmpty) ...[
                            const Text(
                              "Highlighted Projects",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            for (var project in highlightedProjects)
                              _buildHighlightedProjectBlock(project),
                            SizedBox(height: 10),
                            Container(
                              width: w * 0.87,
                              color: Colors.grey,
                              height: 2,
                            ),
                            SizedBox(height: 10),
                          ],
                          const Text(
                            "Experience",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          for (var experience in templateData.experience ?? [])
                            _buildBlock(experience.experienceTitle,
                                experience.experienceDescription),
                          const Text(
                            "Education",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          for (var education in templateData.educationDetails ?? [])
                            _buildBlock(education.schoolLevel, education.schoolName),
                        ],
                      ),
                    ),

                  ],
                ),

                // Skill Section
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Skills",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 21),
                            ),
                            const SizedBox(height: 10),
                            // Display the list of skills
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFF06a2d8)
                              ),
                                child: Column(
                                  children: [
                                    for (var skills in templateData.languages ?? [])
                                      _buildSkill(skills.language, skills.level),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                    ]
                ),
                const SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build the skill category widget
  Widget _buildSkill(String language, int level) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "${language}:",
              softWrap: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8), // Add some space between text and circles
          ...List.generate(5, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < level ?  Colors.blue[900]: Colors.grey[200],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHighlightedProjectBlock(dynamic project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () async {
                  if (project.url != null && project.url.isNotEmpty) {
                    // You may want to use url_launcher for real apps
                  }
                },
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          if (project.customDescription != null && project.customDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text(project.customDescription),
            ),
          if (project.techStack != null && project.techStack.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text('Tech Stack: ${project.techStack.join(", ")}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildBlock(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Name and Link
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          // Project description points
          Container(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: const EdgeInsets.only(left: 2),
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 11
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveSection(
      TemplateData templateData, Function() generateAndPrintResume) {
    return InkWell(
      onTap: generateAndPrintResume,
      child: Container(
        width: 60,
        height: 60,
        color: Colors.grey.shade300,
        child: const Icon(Icons.save),
      ),
    );
  }
}

Future<pw.ImageProvider> loadImage() async {
  final byteData = await rootBundle.load("assets/defaultPerson.png");
  final imageBytes = byteData.buffer.asUint8List();
  return pw.MemoryImage(imageBytes);
}
Future<pw.ImageProvider> loadBackground() async {
  final byteData = await rootBundle.load("assets/background.png");
  final imageBytes = byteData.buffer.asUint8List();
  return pw.MemoryImage(imageBytes);
}

Future<Uint8List> generateResume(PdfPageFormat format, TemplateData data) async {
  final imageProvider = await loadImage();
  final backgroundProvider = await loadBackground();
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) {
        List<pw.Widget> content = [];

        content.add(
            pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: pw.BoxDecoration(
                image: pw.DecorationImage(
                  image: backgroundProvider,
                ),
              ),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Top Portion
                    pw.Row(
                      children: [
                        // Image and details
                        pw.Expanded(
                          flex: 1,
                          child: pw.Column(
                            children: [
                              pw.ClipRRect(
                                horizontalRadius: 35,
                                verticalRadius: 35,
                                child: pw.Image(
                                    imageProvider,
                                    width: 70,
                                    height: 70,
                                    fit: pw.BoxFit.fill
                                ),
                              ),
                              pw.Text(
                                textAlign: pw.TextAlign.center,
                                data.currentPosition ?? "",
                                style: pw.TextStyle(
                                    fontSize: 14, fontWeight: pw.FontWeight.bold),
                              ),
                              if (data.email != null)
                                _UrlText(data.email!, data.email!),
                              if (data.phoneNumber != null)
                                _UrlText(data.phoneNumber!, data.phoneNumber!),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        // Name and profile
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                data.fullName ?? "",
                                style: pw.TextStyle(
                                    fontSize: 27, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Container(
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromInt(0xFF06a2d8),
                                  borderRadius: pw.BorderRadius.circular(10),
                                ),
                                padding: pw.EdgeInsets.all(10),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Profile",
                                      style: pw.TextStyle(
                                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                      data.bio ?? "",
                                      style: pw.TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      color: const PdfColor.fromInt(0xFF222222),
                      height: 2,
                    ),
                    pw.SizedBox(height: 10),

                    // Experience Section
                    if (data.experience != null && data.experience!.isNotEmpty) ...[
                      _Category(title: 'Work Experience'),
                      ...data.experience!.map((experience) => _Block(
                        title: experience.experienceTitle,
                        desc: experience.experienceDescription!,
                      )),
                    ],
                    pw.SizedBox(height: 10),

                    // Education Section
                    if (data.educationDetails != null && data.educationDetails!.isNotEmpty) ...[
                      _Category(title: 'Education'),
                      ...data.educationDetails!.map((education) => _Block(
                        title: education.schoolLevel,
                        desc: education.schoolName,
                      )),
                    ],
                    pw.SizedBox(height: 10),

                    // Skills Section
                    _buildSkillsSection(data),
                  ]
              )
          )
        );
        return content;
      },
    ),
  );
  return pdf.save();
}


pw.Widget _buildSkillsSection(TemplateData templateData) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        "Skills",
        style: pw.TextStyle(
            fontSize: 21,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.brown
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(10),
            color: PdfColor.fromInt(0xFF06a2d8)
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var skill in templateData.languages ?? [])
              _buildSkillRow(skill.language, skill.level),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildSkillRow(String language, int level) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(2.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 110,
          child: pw.Text(
            "$language:",
            softWrap: true,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(width: 8), // Add space between text and circles
        pw.Row(
          children: List.generate(5, (index) {
            return pw.Container(
              margin: const pw.EdgeInsets.symmetric(horizontal: 2),
              width: 20,
              height: 20,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: index < level ?  PdfColors.blue900: PdfColors.grey200,
              ),
            );
          }),
        ),
      ],
    ),
  );
}

class _Block extends pw.StatelessWidget {
  _Block({required this.title, this.icon, required this.desc});

  final String title;
  final String desc;

  final pw.IconData? icon;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(title,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(desc),
        ]
    );
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title});

  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Text(
      title,
      textScaleFactor: 1.5,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.brown,
      ),
    );
  }
}

class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
      destination: url,
      child: pw.Text(text,
          style: const pw.TextStyle(
            decoration: pw.TextDecoration.underline,
            color: PdfColors.blue900,
            fontSize: 14
          )),
    );
  }
}