import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/settings_provider.dart';

class CustomSlider extends StatelessWidget {
  const CustomSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        valueIndicatorShape: NotchedValueIndicatorShape(
          width: 80.w,
          height: 30.h,
          notchWidth: 12.w,
          notchHeight: 6.h,
        ),
        valueIndicatorColor: Colors.black,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.grey[250],
        trackHeight: 8.h,
        thumbColor: Colors.blue,
        thumbShape: CircleThumbWithBorder(
          outerRadius: 10.r,
          innerRadius: 7.r,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final quality =
              ref.watch(settingsProvider.select((state) => state.quality));

          return Slider(
            padding: EdgeInsets.all(10.r),
            value: quality,
            min: 0,
            max: 100,
            divisions: 100,
            label: "${quality.toInt()}%",
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateQuality(value);
            },
          );
        },
      ),
    );
  }
}

class NotchedValueIndicatorShape extends SliderComponentShape {
  final double width;
  final double height;
  final double notchHeight;
  final double notchWidth;

  NotchedValueIndicatorShape({
    this.width = 40,
    this.height = 30,
    this.notchHeight = 8,
    this.notchWidth = 12,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height + notchHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.valueIndicatorColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    final top = center.dy - height - notchHeight - 8;
    final rectTopLeft = Offset(center.dx - width / 2, top);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(rectTopLeft.dx, rectTopLeft.dy, width, height),
      Radius.circular(8.r),
    );

    // Create a V-notch path
    final notchPath = Path()
      ..addRRect(rect)
      ..moveTo(center.dx - notchWidth / 2, top + height)
      ..lineTo(center.dx, top + height + notchHeight)
      ..lineTo(center.dx + notchWidth / 2, top + height)
      ..close();

    canvas.drawPath(notchPath, paint);

    // Draw label text
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        top + (height - labelPainter.height) / 2,
      ),
    );
  }
}

class CircleThumbWithBorder extends SliderComponentShape {
  final double outerRadius;
  final double innerRadius;

  CircleThumbWithBorder({
    this.outerRadius = 12.0,
    this.innerRadius = 8.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(outerRadius * 2, outerRadius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer black border (border)
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Outer white circle (padding)
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Inner circle (actual thumb color)
    final innerPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, outerRadius, borderPaint);
    canvas.drawCircle(center, outerRadius, outerPaint);
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
}
