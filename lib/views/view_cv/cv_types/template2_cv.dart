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

class ResumeScreen4 extends StatelessWidget {
  final TemplateData templateData;
  final List<HighlightedProject> highlightedProjects;
  const ResumeScreen4({super.key, required this.templateData, required this.highlightedProjects});

  Future<void> _generateAndPrintResume(BuildContext context) async {
    final pdfData = await generateResume(PdfPageFormat.a4, templateData, highlightedProjects);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {

    final regularFont = pw.Font.helvetica();
    // Color definitions
    final headerColor = Colors.brown;
    final lineColor = Colors.grey;

    return Scaffold(
      floatingActionButton: _buildSideSection(
          templateData, () => _generateAndPrintResume(context)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    templateData.fullName ?? "",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    templateData.currentPosition ?? "",
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: headerColor,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Contact Info in a Box with clickable links
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: headerColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(templateData.email ?? ""),
                        Text(templateData.phoneNumber ?? ""),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Summary
              Text(
                templateData.bio ?? ""
              ),
              SizedBox(height: 20),

              // Experience
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Experience",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: headerColor,
                          ),
                        ),
                        Divider(color: lineColor,),
                        for (var experience in templateData.experience ?? [])
                          _buildBlock(experience.experienceTitle,
                              experience.experienceDescription),
                      ],
                    ),
                  ),
                ],
              ),

              // Education
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Education",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: headerColor,
                          ),
                        ),
                        Divider(color: lineColor,),
                        for (var education in templateData.educationDetails ?? [])
                          _buildBlock(education.schoolLevel, education.schoolName),
                      ],
                    ),
                  ),
                ],
              ),

              // Skills (Split into two columns)
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Skills",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: headerColor,
                            ),
                          ),
                          Divider(color: lineColor),
                          const SizedBox(height: 4,),
                          // Display the list of skills
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: headerColor
                                  )
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
            ],
          ),
        ),
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

  Widget _buildSkill(String language, int level) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
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
                color: index < level ?  Colors.deepOrange[600]: Colors.orange[100],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSideSection(
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

Future<Uint8List> generateResume(PdfPageFormat format, TemplateData data, List<HighlightedProject> highlightedProjects) async {
  final pdf = pw.Document(title: '${data.fullName} Résumé', author: data.fullName);

  // Fetch profile image dynamically

  final headerColor = PdfColors.brown;

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) {
        List<pw.Widget> content = [];

        content.add(
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (highlightedProjects.isNotEmpty) ...[
                  pw.Text(
                    "Highlighted Projects",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                  ),
                  pw.SizedBox(height: 5),
                  for (var project in highlightedProjects)
                    _buildHighlightedProjectBlock(project),
                  pw.SizedBox(height: 10),
                ],
                // Header Section
                pw.Text(
                  data.fullName ?? "",
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  data.currentPosition ?? "",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontStyle: pw.FontStyle.italic,
                    color: headerColor,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Contact Information Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: headerColor,
                      width: 1,
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      if (data.email != null)
                        _UrlText(data.email!, data.email!),
                      if (data.phoneNumber != null)
                        pw.Text(
                          data.phoneNumber!,
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Summary Section
                if (data.bio != null && data.bio!.isNotEmpty)
                  pw.Text(
                    data.bio!,
                    style: pw.TextStyle(fontSize: 14),
                  ),
                pw.SizedBox(height: 20),

                // Experience Section
                if (data.experience != null && data.experience!.isNotEmpty) ...[
                  _Category(title: 'Work Experience'),
                  ...data.experience!.map((experience) => _Block(
                    title: experience.experienceTitle,
                    desc: experience.experienceDescription!,
                  )),
                ],

                // Education Section
                if (data.educationDetails != null && data.educationDetails!.isNotEmpty) ...[
                  _Category(title: 'Education'),
                  ...data.educationDetails!.map((education) => _Block(
                    title: education.schoolLevel,
                    desc: education.schoolName,
                  )),
                ],

                // Skills Section
                _buildSkillsSection(data),
              ],
            ),
          ),
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
          border: pw.Border.all(
            color: PdfColors.brown
          )
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
                color: index < level ?  PdfColors.deepOrange: PdfColors.orange100,
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
          fontSize: 18,
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
            color: PdfColors.blue,
          )),
    );
  }
}

pw.Widget _buildHighlightedProjectBlock(dynamic project) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Icon(pw.IconData(0xe838), color: PdfColors.amber, size: 18),
            pw.SizedBox(width: 6),
            pw.Text(
              project.name,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ],
        ),
        if (project.customDescription != null && project.customDescription.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 24, top: 2),
            child: pw.Text(project.customDescription),
          ),
        if (project.techStack != null && project.techStack.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 24, top: 2),
            child: pw.Text('Tech Stack: ${project.techStack.join(", ")}', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 12)),
          ),
      ],
    ),
  );
}