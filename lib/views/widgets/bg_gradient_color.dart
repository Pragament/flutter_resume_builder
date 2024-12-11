import 'package:flutter/material.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';

class BgGradientColor extends StatelessWidget {
  const BgGradientColor(
      {super.key,
      required this.child,
      this.borderRadius = BorderRadius.zero,
      this.colors = const [
        AppColors.primaryColor,
        Color(0xFF2A74B0),
        AppColors.primaryColor,
      ]});
  final Widget child;
  final BorderRadius borderRadius;
  final List<Color> colors;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors)),
      child: child,
    );
  }
}
