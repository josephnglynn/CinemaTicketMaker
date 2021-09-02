import 'package:flutter/cupertino.dart';

class CustomTextPainter extends TextPainter {
  CustomTextPainter({
    InlineSpan? text,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
    double textScaleFactor = 1.0,
    int? maxLines,
    String? ellipsis,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
  }) : super(
          text: text,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          ellipsis: ellipsis,
          locale: locale,
          strutStyle: strutStyle,
          textHeightBehavior: textHeightBehavior,
          textWidthBasis: textWidthBasis,
        );

  void fitCertainWidth(double widthOfConstraint) {
    double decrease = 0.05;
    layout();
    if (width < widthOfConstraint) return;
    final content = text!.toPlainText();
    var style = text!.style ?? const TextStyle();
    double fontSize = style.fontSize ?? 30;
    while (width > widthOfConstraint) {
      print("CALLED LOOP");
      fontSize -= decrease;
      style = style.copyWith(fontSize: fontSize);

      text = TextSpan(
        text: content,
        style: style,
      );

      layout();

      if (fontSize < 0.1) {
        return;
      }
    }
  }
}
