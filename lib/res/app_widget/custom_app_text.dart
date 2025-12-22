import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppText extends StatelessWidget {
  const AppText(
      this.data, {
        super.key,
        this.color,
        this.fontSize = 16,
        this.maxLines,
        this.fontWeight,
        this.textDecoration,
        this.overflow,
        this.textAlign = TextAlign.start,
        this.textHeight,
        this.letterSpacing,
      });

  const AppText.small(
      this.data, {
        super.key,
        this.color,
        this.fontSize = 12,
        this.maxLines,
        this.fontWeight = FontWeight.w400,
        this.textDecoration,
        this.overflow,
        this.textAlign = TextAlign.start,
        this.textHeight,
        this.letterSpacing,
      });

  const AppText.medium(
      this.data, {
        super.key,
        this.color,
        this.fontSize = 14,
        this.maxLines,
        this.textDecoration,
        this.fontWeight = FontWeight.w500,
        this.overflow,
        this.textAlign = TextAlign.start,
        this.textHeight,
        this.letterSpacing,
      });

  const AppText.large(
      this.data, {
        super.key,
        this.color,
        this.fontSize = 23,
        this.maxLines,
        this.fontWeight = FontWeight.w700,
        this.textDecoration,
        this.overflow,
        this.textAlign = TextAlign.start,
        this.textHeight,
        this.letterSpacing,
      });

  const AppText.regular(
      this.data, {
        super.key,
        this.color,
        this.fontSize = 16,
        this.maxLines = 3,
        this.textDecoration,
        this.fontWeight = FontWeight.w400,
        this.overflow = TextOverflow.ellipsis,
        this.textAlign = TextAlign.start,
        this.textHeight,
        this.letterSpacing,
      });

  const AppText.bold(
      this.data, {
        super.key,
        this.color,
        this.fontSize = 16,
        this.textDecoration,
        this.maxLines = 2,
        this.fontWeight = FontWeight.w700,
        this.overflow = TextOverflow.ellipsis,
        this.textAlign = TextAlign.start,
        this.textHeight,
        this.letterSpacing,
      });

  final String data;
  final Color? color;
  final double? fontSize;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;
  final TextOverflow? overflow;
  final double? textHeight;
  final double? letterSpacing;

  static double getAdaptiveFontSize(BuildContext context, {double? fontSize}) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final baseFontSize = fontSize ?? 16.0;
    if (isTablet) {
      return (baseFontSize * 0.8).sp;
    }
    return baseFontSize.sp;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      overflow: overflow,
      style: TextStyle(
        color: color ?? Colors.white,
        fontSize: getAdaptiveFontSize(context, fontSize: fontSize),
        height: textHeight ?? 1.2,
        fontWeight: fontWeight,
        decoration: textDecoration,
        decorationColor: color,
        letterSpacing: letterSpacing?.sp,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
