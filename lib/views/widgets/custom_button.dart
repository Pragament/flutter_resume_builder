import 'package:flutter/material.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class CustomButton extends StatelessWidget {
  CustomButton({super.key,required this.title,this.onPressed,this.borderRadius = const BorderRadius.all(Radius.circular(12)),this.isLoading=false});
  String title;
  VoidCallback? onPressed;
  BorderRadius borderRadius;
  bool isLoading;

  @override
  Widget build(BuildContext context) {
    return BgGradientColor(
        borderRadius:  borderRadius,
        child: ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        shape:WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius
          )
        )
      ),
      child:isLoading? const CircularProgressIndicator(color: Colors.white): Text(title,style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),),
    ));
  }
}
