import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/data.dart';
class SampleTemplate extends StatefulWidget {
  const SampleTemplate({super.key});

  @override
  State<SampleTemplate> createState() => _SampleTemplateState();
}

class _SampleTemplateState extends State<SampleTemplate> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late TemplateTheme theme = TemplateTheme.modern;
  GlobalKey key=GlobalKey();
  List<TemplateTheme> list = [
    TemplateTheme.classic,
    TemplateTheme.modern,
    TemplateTheme.technical,
    TemplateTheme.business,
  ];

  void getRandomItem(BuildContext context) {
    final random = Random();
    final index = random.nextInt(4);
    theme = list[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  getRandomItem(context);
                  _scaffoldKey.currentState?.closeDrawer();
                });
              },
              child: const Text('Change Theme'),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RepaintBoundary(
              key: key,
              child: SizedBox(
                child: FlutterResumeTemplate(
                  data: data,
                  imageHeight: 100,
                  imageWidth: 100,
                  height: 2000,
                  emailPlaceHolder: 'Email:',
                  telPlaceHolder: 'No:',
                  experiencePlaceHolder: 'Past',
                  educationPlaceHolder: 'School',
                  languagePlaceHolder: 'Skills',
                  aboutMePlaceholder: 'Me',
                  hobbiesPlaceholder: 'Projects',
                  mode: TemplateMode.onlyEditableMode,
                  showButtons: true,
                  imageBoxFit: BoxFit.fitHeight,
                  backgroundColorLeftSection: Colors.blue,
                  enableDivider: false,
                  onEmpty: (context){
                    return Container(
                        color: Colors.blue,
                        child: const Text(" Resume"));
                  },
                  onSaveResume: (key)async{
                    return await PdfHandler().createPDF(key);
                  },
                  //backgroundColorLeftSection: Colors.amber,
                  templateTheme: TemplateTheme.technical,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          try {
            final pdf = pw.Document();

            // Capture the widget as an image
            final image = await _capturePng(key);

            // Add the image to a PDF page
            pdf.addPage(
              pw.Page(
                pageFormat: const PdfPageFormat(200,700,marginAll: 0.0),
                margin: pw.EdgeInsets.zero, // Removes the default margin
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Image(pw.MemoryImage(image), fit: pw.BoxFit.contain,),
                  );
                },
              ),
            );

            // Get the temporary directory and save the file
            final output = await getTemporaryDirectory();
            final file = File("${output.path}/resume.pdf");
            print(file.path);
            await file.writeAsBytes(await pdf.save());

          // Optionally, share or print the PDF
          await Printing.sharePdf(bytes: await pdf.save(), filename: 'resume.pdf');
          } catch (e) {
          print('Error generating PDF: $e');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  Future<Uint8List> _capturePng(GlobalKey key) async {
    RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 4.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
