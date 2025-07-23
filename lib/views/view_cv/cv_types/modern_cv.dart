import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';

class ResumeScreen2 extends StatelessWidget {
  final TemplateData templateData;
  final List<HighlightedProject> highlightedProjects;

  const ResumeScreen2({super.key, required this.templateData, required this.highlightedProjects});

  Future<void> _generateAndPrintResume(BuildContext context) async {
    final pdfData = await generateResume(PdfPageFormat.a4, templateData);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(templateData),
                    const SizedBox(height: 20),
                    if (highlightedProjects.isNotEmpty) ...[
                      _buildCategory('Highlighted Projects'),
                      for (var project in highlightedProjects)
                        _buildHighlightedProjectBlock(project),
                      const SizedBox(height: 20),
                    ],
                    _buildCategory('Work Experience'),
                    for (var experience in templateData.experience ?? [])
                      _buildBlock(experience.experienceTitle,
                          experience.experienceDescription),
                    const SizedBox(height: 20),
                    _buildCategory('Education'),
                    for (var education in templateData.educationDetails ?? [])
                      _buildBlock(education.schoolLevel, education.schoolName),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            _buildSideSection(
                templateData, () => _generateAndPrintResume(context)),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileHeader(TemplateData data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        data.fullName,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      if (data.currentPosition != null)
        Text(
          data.currentPosition!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.street != null) Text(data.street!),
                if (data.address != null) Text(data.address!),
                if (data.country != null) Text(data.country!),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.phoneNumber != null) Text(data.phoneNumber!),
                if (data.email != null)
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      data.email!,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildCategory(String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(6),
    ),
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildBlock(String title, String desc) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.blue, width: 2)),
        ),
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        margin: const EdgeInsets.only(left: 5),
        child: Text(desc),
      ),
      const SizedBox(height: 10),
    ],
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

Widget _buildSideSection(
    TemplateData templateData, Function() generateAndPrintResume) {
  return Expanded(
    flex: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 35.sp,
          backgroundColor: AppColors.primaryColor,
          backgroundImage: templateData.image != null
              ? FileImage(File(templateData.image!))
              : null,
          child: templateData.image == null
              ? Icon(
                  Icons.person,
                  size: 50.sp,
                  color: Colors.white,
                )
              : null,
        ),
        Column(
          children: [
            if (templateData.languages != null)
              for (var language in templateData.languages!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: _buildSkillMeter(language.language,
                      language.level / 5), // Assuming level is out of 10
                ),
          ],
        ),
        // Simulate QR code with a placeholder image
        InkWell(
          onTap: generateAndPrintResume,
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade300,
            child: const Icon(Icons.save),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSkillMeter(String skill, double level) {
  return Column(
    children: [
      Text(skill),
      SizedBox(
        width: 60, // Adjust size as needed
        height: 60, // Adjust size as needed
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: level,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
              strokeWidth: 5, // Adjust stroke width as needed
            ),
            Text(
              '${(level * 100).round()}%', // Display percentage
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  );
}

const PdfColor blue = PdfColor.fromInt(0xff007bff); // A standard blue color
const PdfColor lightblue = PdfColor.fromInt(0xffadd8e6); // Light blue color

Future<Uint8List> generateResume(
    PdfPageFormat format, TemplateData data) async {
  final doc =
      pw.Document(title: '${data.fullName} Résumé', author: data.fullName);

  // Fetch profile image dynamically
  final response = await http.get(Uri.parse(data.image ??
      'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg'));
  final profileImage = pw.MemoryImage(response.bodyBytes);

  final pageTheme = await _myPageTheme(format);
  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) {
        List<pw.Widget> contentLeft = [];
        List<pw.Widget> contentRight = [];

        // Add Profile Header to the left side
        contentLeft.add(
          pw.Container(
            padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                // Left content
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: <pw.Widget>[
                          // Column for full name, position, and address
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Text(data.fullName,
                                  textScaleFactor: 2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          fontWeight: pw.FontWeight.bold)),
                              if (data.currentPosition != null)
                                pw.Text(data.currentPosition!,
                                    textScaleFactor: 1.2,
                                    style: pw.Theme.of(context)
                                        .defaultTextStyle
                                        .copyWith(
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.green)),
                              pw.Text(data.address!,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          fontWeight: pw.FontWeight.normal)),
                            ],
                          ),
                          pw.SizedBox(width: 20), // Space between columns
                          // Column for phone and email
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(data.phoneNumber!,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          fontWeight: pw.FontWeight.normal)),
                              _UrlText(data.email!, data.email!)
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Spacer to push the profile image to the far right
                pw.SizedBox(width: 350),
                // Profile picture container on the far right
                pw.Container(
                  width: 100,
                  height: 100,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    image: pw.DecorationImage(
                      image: profileImage,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        // Add Work Experience to the left side
        if (data.experience != null && data.experience!.isNotEmpty) {
          contentLeft.add(_Category(title: 'Work Experience'));
          contentLeft.addAll(data.experience!.map((experience) => _Block(
                title: experience.experienceTitle,
                desc: experience.experienceDescription!,
              )));
        }

        // Add Education to the left side
        if (data.educationDetails != null &&
            data.educationDetails!.isNotEmpty) {
          contentLeft.add(_Category(title: 'Education'));
          contentLeft.addAll(data.educationDetails!.map((education) => _Block(
                title: education.schoolLevel,
                desc: education.schoolName,
              )));
        }

        // Add Languages to the right side
        if (data.languages != null && data.languages!.isNotEmpty) {
          contentRight.add(
            pw.SizedBox(height: 120),
          );
          contentRight.add(
            _Category(title: 'Languages'),
          );
          contentRight.addAll(data.languages!.map((language) => _Percent(
                size: 50,
                value: language.level / 5,
                title: pw.Text(language.language),
              )));
        }

        return [
          pw.Partitions(
            children: [
              pw.Partition(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: contentLeft,
                ),
              ),
              pw.Partition(
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.end, // Align to the far right
                  children: contentRight,
                ),
              ),
            ],
          ),
        ];
      },
    ),
  );

  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  final bgShape = await rootBundle.loadString('assets/resume.svg');

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 4.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              child: pw.SvgImage(svg: bgShape),
              left: 0,
              top: 0,
            ),
            pw.Positioned(
              child: pw.Transform.rotate(
                  angle: pi, child: pw.SvgImage(svg: bgShape)),
              right: 0,
              bottom: 0,
            ),
          ],
        ),
      );
    },
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
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 6,
                  height: 6,
                  margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                    color: blue,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Text(title,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(fontWeight: pw.FontWeight.bold)),
                pw.Spacer(),
                if (icon != null) pw.Icon(icon!, color: lightblue, size: 18),
              ]),
          pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: blue, width: 2))),
            padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: const pw.EdgeInsets.only(left: 5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(desc),
                ]),
          ),
        ]);
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title});

  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        color: lightblue,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      margin: const pw.EdgeInsets.only(bottom: 10, top: 20),
      padding: const pw.EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: pw.Text(
        title,
        textScaleFactor: 1.5,
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

class _Percent extends pw.StatelessWidget {
  _Percent({
    required this.size,
    required this.value,
    required this.title,
  });

  final double size;
  final double value; // Expecting value as a percentage (0-1)
  final pw.Widget title;

  static const fontSize = 1.2;
  static const backgroundColor = PdfColors.grey300;
  static const strokeWidth = 5.0;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      children: [
        pw.Container(
          width: size,
          height: size,
          child: pw.Stack(
            alignment: pw.Alignment.center,
            fit: pw.StackFit.expand,
            children: [
              pw.CircularProgressIndicator(
                value: value,
                backgroundColor: backgroundColor,
                color: PdfColors.blue,
                strokeWidth: strokeWidth,
              ),
              pw.Center(
                child: pw.Text(
                  '${(value * 100).round().toInt()}%',
                  textScaleFactor: fontSize,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        title,
      ],
    );
  }
}
