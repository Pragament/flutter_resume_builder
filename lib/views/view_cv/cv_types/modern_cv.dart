import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:resume_builder_app/main.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resume_builder_app/views/widgets/custom_button.dart';

class ModernCv extends StatefulWidget {
  const ModernCv({super.key,required this.templateData});
  final TemplateData templateData;

  @override
  State<ModernCv> createState() => _ModernCvState();
}

class _ModernCvState extends State<ModernCv> with SingleTickerProviderStateMixin {
  GlobalKey key=GlobalKey();
  double height=1800;
  bool isLoading=false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: RepaintBoundary(
        key: key,
        child: FlutterResumeTemplate(
          data: widget.templateData,
          templateTheme: TemplateTheme.modern,
          imageHeight: 100,
          imageWidth: 100,
          emailPlaceHolder: 'Email:',
          telPlaceHolder: 'No:',
          height: height,
          width: 1.6.sw,
          experiencePlaceHolder: 'Experience',
          educationPlaceHolder: 'Education',
          languagePlaceHolder: 'Skills',
          aboutMePlaceholder: 'About Me',
          hobbiesPlaceholder: 'Hobbies',
          mode: TemplateMode.onlyEditableMode,
          showButtons: true,
          imageBoxFit: BoxFit.fitHeight,
          backgroundColorLeftSection: Colors.blue,
          enableDivider: false,
        ),
      ),
      floatingActionButton: SizedBox(
        height: 100.h,
        child: Column(
          children: [
            SizedBox(
              height: 40.h,
              width: 40.w,
              child: FloatingActionButton(
                heroTag: "modern_zoom+",
                onPressed: (){
                  height=height-100;
                  setState(() {

                  });
                },
                backgroundColor: AppColors.primaryColor,child: Icon(Icons.zoom_in,color: Colors.white,size: 20.sp,),),
            ),
            SizedBox(height: 8.w,),
            SizedBox(
              height: 40.h,
              width: 40.w,
              child: FloatingActionButton(
                heroTag: "modern_zoom-",
                onPressed: (){
                  height=height+100;
                  setState(() {
                    print(height);
                  });
                },
                backgroundColor: AppColors.primaryColor,child: Icon(Icons.zoom_out,color: Colors.white,size: 20.sp,),),
            ),        ],
        ),
      ),
      bottomSheet: InkWell(
        onTap: saveResume,
        child: SizedBox(
          width: 1.sw,
          height: 70.h,
          child: CustomButton(
            title: 'Save',
            isLoading: isLoading,
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),

    );
  }

  Future<Uint8List> _capturePng(GlobalKey key) async {
    RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 4.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> saveResume()async{
    try {
      setState(() {
        isLoading=true;
      });
      final pdf = pw.Document();

      // Capture the widget as an image
      final image = await _capturePng(key);
      final memoryImage=pw.MemoryImage(image);

      // Add the image to a PDF page
      pdf.addPage(
        pw.Page(
          pageFormat:  PdfPageFormat(memoryImage.width?.toDouble() ?? 200 ,memoryImage.height?.toDouble()?? 700,marginAll: 0.0),
          margin: pw.EdgeInsets.zero, // Removes the default margin
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(memoryImage, fit: pw.BoxFit.contain,),
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
      setState(() {
        isLoading=false;
      });
    } catch (e) {
      setState(() {
        isLoading=false;
      });
      print('Error generating PDF: $e');
    }
  }

}
