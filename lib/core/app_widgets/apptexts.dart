import 'package:aptcoder/core/config/const.dart';
import 'package:flutter/widgets.dart';

class AppText extends Text {
  const AppText(
    super.data, {
    super.key,
    required TextStyle super.style,
    super.textAlign,
    super.overflow,
    super.maxLines,
  });

  // ---------------------------
  // BASE STYLE HELPERS
  // ---------------------------
  static TextStyle _inter(double size, FontWeight weight, bool italic) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  static TextStyle _urbanist(double size, FontWeight weight, bool italic) =>
      TextStyle(
        fontFamily: 'Urbanist',
        fontSize: size,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  // ---------------------------
  // SIZE CONSTANTS
  // ---------------------------
  static const double _mini = AppFontSize.mini;
  static const double _small = AppFontSize.small;
  static const double _medium = AppFontSize.medium;
  static const double _large = AppFontSize.large;
  static const double _larger = AppFontSize.larger;
  static const double _largest = AppFontSize.largest;
  static const double _huge = AppFontSize.huge;

  // #############################################################
  // #   INTER (ROMAN)
  // #############################################################

  AppText.interMini(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _inter(_mini, weight, false).copyWith(color: color));

  AppText.interSmall(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _inter(_small, weight, false).copyWith(color: color));

  AppText.interMedium(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _inter(_medium, weight, false).copyWith(color: color));

  AppText.interLarge(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _inter(_large, weight, false).copyWith(color: color));

  AppText.interLarger(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) : super(style: _inter(_larger, weight, false).copyWith(color: color));

  AppText.interLargest(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) : super(style: _inter(_largest, weight, false).copyWith(color: color));

  AppText.interHuge(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) : super(style: _inter(_huge, weight, false).copyWith(color: color));

  // #############################################################
  // #   INTER (ITALIC)
  // #############################################################

  AppText.interMiniItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _inter(_mini, weight, true).copyWith(color: color));

  AppText.interSmallItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _inter(_small, weight, true).copyWith(color: color));

  AppText.interMediumItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _inter(_medium, weight, true).copyWith(color: color));

  AppText.interLargeItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _inter(_large, weight, true).copyWith(color: color));

  AppText.interLargerItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) : super(style: _inter(_larger, weight, true).copyWith(color: color));

  AppText.interLargestItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) : super(style: _inter(_largest, weight, true).copyWith(color: color));

  // #############################################################
  // #   URBANIST (ROMAN)
  // #############################################################

  AppText.urbanMini(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _urbanist(_mini, weight, false).copyWith(color: color));

  AppText.urbanSmall(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _urbanist(_small, weight, false).copyWith(color: color));

  AppText.urbanMedium(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _urbanist(_medium, weight, false).copyWith(color: color));

  AppText.urbanLarge(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _urbanist(_large, weight, false).copyWith(color: color));

  AppText.urbanLarger(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) : super(style: _urbanist(_larger, weight, false).copyWith(color: color));

  AppText.urbanLargest(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) : super(style: _urbanist(_largest, weight, false).copyWith(color: color));

  // #############################################################
  // #   URBANIST (ITALIC)
  // #############################################################

  AppText.urbanMiniItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _urbanist(_mini, weight, true).copyWith(color: color));

  AppText.urbanSmallItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) : super(style: _urbanist(_small, weight, true).copyWith(color: color));

  AppText.urbanMediumItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _urbanist(_medium, weight, true).copyWith(color: color));

  AppText.urbanLargeItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) : super(style: _urbanist(_large, weight, true).copyWith(color: color));

  AppText.urbanLargerItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) : super(style: _urbanist(_larger, weight, true).copyWith(color: color));

  AppText.urbanLargestItalic(
    super.text, {
    super.key,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) : super(style: _urbanist(_largest, weight, true).copyWith(color: color));
}
