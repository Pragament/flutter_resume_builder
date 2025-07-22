import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:pdf/pdf.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import '../../../utils/routes/app_colors.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';

class ResumeScreen5 extends StatelessWidget {
  final TemplateData templateData;
  final List<HighlightedProject> highlightedProjects;

  const ResumeScreen5({super.key, required this.templateData, required this.highlightedProjects});

  Future<void> _generateAndPrintResume(BuildContext context) async {
    final pdfData = await generateResume(PdfPageFormat.a4, templateData);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildSaveSection(
          templateData, () => _generateAndPrintResume(context)),
      body: Stack(
        children: [
          // Background color covering the whole screen
          Container(
            color: Colors.indigo[900],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.only(left: 5),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          templateData.fullName ?? "",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          templateData.currentPosition ?? "",
                          style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Professional Summary',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          templateData.bio ?? "",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
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
                                    ),
                                  ),
                                  for (var experience in templateData.experience ?? [])
                                    _buildBlock(experience.experienceTitle, experience.experienceDescription),
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
                                    ),
                                  ),
                                  for (var education in templateData.educationDetails ?? [])
                                    _buildBlock(education.schoolLevel, education.schoolName),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (highlightedProjects.isNotEmpty) ...[
                          const Text(
                            "Highlighted Projects",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          for (var project in highlightedProjects)
                            _buildHighlightedProjectBlock(project),
                          SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Center(
                          child: CircleAvatar(
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
                        ),
                        const SizedBox(height: 40,),
                        // Personal Details i.e, email, phone etc
                        const Text(
                          'Personal Details',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40,),
                        Text(
                          templateData.phoneNumber ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 5,),
                        Text(
                          templateData.email ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 40,),

                        // Skills
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 15,),
                                  const Text(
                                    "Skills",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    children: [
                                      for (var skills in templateData.languages ?? [])
                                        _buildSkill(skills.language, skills.level),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.only(top: 5),
            margin: const EdgeInsets.only(left: 2),
            child: Text(
              desc,
              style: const TextStyle(fontSize: 11),
            ),
          ),
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

  Widget _buildSkill(String language, int level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "${language}:",
              softWrap: true,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
          const SizedBox(height: 4,),
          LinearPercentIndicator(
            barRadius: Radius.circular(2),
            lineHeight: 10.0,
            percent: level/5,
            padding: EdgeInsets.zero,
            linearStrokeCap: LinearStrokeCap.roundAll,
            backgroundColor: Colors.grey,
            progressColor: Colors.white,
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

Future<Uint8List> generateResume(PdfPageFormat format, TemplateData data) async {
  final imageProvider = await loadImage();
  final pdf = pw.Document();

  final pw.PageTheme pageTheme = pw.PageTheme(
    pageFormat: PdfPageFormat.a4, // Define the page size (A4 in this case)
    buildBackground: (pw.Context context) {
      // Create a container to represent the page background
      return pw.Container(
        width: double.infinity,
        height: double.infinity,
        child: pw.Row(
          children: [
            // Left side (5 parts white)
            pw.Expanded(
                flex: 5,
                child: pw.Container(
                    color: PdfColors.white
                )
            ),
            // Right side (3 parts indigo)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  color: PdfColors.indigo900,
                )
            ),
          ],
        ),
      );
    },
  );


  pdf.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) {
        List<pw.Widget> contentLeft = [];
        List<pw.Widget> contentRight = [];

        // Add personal and professional summary to the left side
        contentLeft.add(
          pw.Container(
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        data.fullName ?? "",
                        style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        data.currentPosition ?? "",
                        style: pw.TextStyle(fontSize: 20, color: PdfColors.grey500),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Professional Summary',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        data.bio ?? "",
                        style: pw.TextStyle(fontSize: 16),
                      ),
                      pw.SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        contentLeft.add(pw.SizedBox(height: 20));
        // Add Work Experience
        if (data.experience != null && data.experience!.isNotEmpty) {
          contentLeft.add(_Category(title: 'Work Experience'));
          contentLeft.addAll(data.experience!.map((experience) => _Block(
            title: experience.experienceTitle,
            desc: experience.experienceDescription ?? 'No Description',
          )));
        }

        contentLeft.add(pw.SizedBox(height: 20));
        // Add Education
        if (data.educationDetails != null && data.educationDetails!.isNotEmpty) {
          contentLeft.add(_Category(title: 'Education'));
          contentLeft.addAll(data.educationDetails!.map((education) => _Block(
            title: education.schoolLevel,
            desc: education.schoolName,
          )));
        }

        // Add Skills to the right side
        contentRight.add(_buildRightSection(data, imageProvider));

        return [
          pw.Partitions(
            children: [
              pw.Partition(
                flex: 5, // Make the left side larger
                child: pw.Container(
                  // color: PdfColors.white,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: contentLeft,
                  ),
                ),
              ),
              pw.Partition(
                flex: 3, // Make the right side smaller
                child: pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: contentRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

// Function to build the skills section
pw.Widget _buildRightSection(TemplateData templateData, final imageProvider) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 50),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.ClipRRect(
            horizontalRadius: 35,
            verticalRadius: 35,
            child: pw.Image(
                imageProvider,
                width: 70,
                height: 70,
                fit: pw.BoxFit.fill
            ),
          ),
        ),
        pw.SizedBox(height: 40,),
        // Personal Details i.e, email, phone etc
        pw.Text(
          'Personal Details',
          style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 40,),
        if (templateData.phoneNumber != null)
          _UrlText(templateData.phoneNumber!, templateData.phoneNumber!),
        pw.SizedBox(height: 5,),
        if (templateData.email != null)
          _UrlText(templateData.email!, templateData.email!),
        pw.SizedBox(height: 40,),
        pw.Text(
          "Skills",
          style: pw.TextStyle(
            fontSize: 21,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var skill in templateData.languages ?? [])
              _buildSkillRow(skill.language, skill.level),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildSkillRow(String language, int level) {
  final double percent = level / 5;

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 2.0, vertical: 7),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 70,
          child: pw.Text(
            "${language}:",
            softWrap: true,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 10,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey,
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Stack(
            children: [
              pw.Container(
                width: percent * 100, // Adjust based on a scale of 100
                height: 10,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
            ],
          ),
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
    return pw.Padding(
      padding: pw.EdgeInsets.only(right: 4.0),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(title,
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(desc),
          ]
      ),
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
            color: PdfColors.white,
            fontSize: 14
          )),
    );
  }
}


// Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
//   final bgShape = await rootBundle.loadString('assets/resume.svg');
//
//   format = format.applyMargin(
//       left: 2.0 * PdfPageFormat.cm,
//       top: 4.0 * PdfPageFormat.cm,
//       right: 2.0 * PdfPageFormat.cm,
//       bottom: 2.0 * PdfPageFormat.cm);
//   return pw.PageTheme(
//     pageFormat: format,
//     theme: pw.ThemeData.withFont(
//       base: await PdfGoogleFonts.openSansRegular(),
//       bold: await PdfGoogleFonts.openSansBold(),
//       icons: await PdfGoogleFonts.materialIcons(),
//     ),
//     buildBackground: (pw.Context context) {
//       return pw.FullPage(
//         ignoreMargins: true,
//         child: pw.Stack(
//           children: [
//             pw.Positioned(
//               child: pw.SvgImage(svg: bgShape),
//               left: 0,
//               top: 0,
//             ),
//             pw.Positioned(
//               child: pw.Transform.rotate(
//                   angle: pi, child: pw.SvgImage(svg: bgShape)),
//               right: 0,
//               bottom: 0,
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }


// pw.Widget _buildSkillRow(String language, int level) {
//   return pw.Padding(
//     padding: const pw.EdgeInsets.symmetric(horizontal: 2.0, vertical: 7),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.SizedBox(
//           width: 70,
//           child: pw.Text(
//             "${language}:",
//             softWrap: true,
//             style: pw.TextStyle(
//                 fontSize: 14,
//                 fontWeight: pw.FontWeight.bold,
//                 color: PdfColors.white
//             ),
//           ),
//         ),
//         pw.SizedBox(height: 4,),
//         pw.LinearPercentIndicator(
//           barRadius: Radius.circular(2),
//           lineHeight: 10.0,
//           percent: level/5,
//           padding: EdgeInsets.zero,
//           linearStrokeCap: LinearStrokeCap.roundAll,
//           backgroundColor: Colors.grey,
//           progressColor: Colors.white,
//         ),
//       ],
//     ),
//   );
// }