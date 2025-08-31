import 'package:flutter/material.dart';

import 'app_text.dart';

class AppPrice extends StatelessWidget {
  final String? priceString;
  final double? rsSize;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String price;
  final Color? color;
  const AppPrice({
    super.key,
    required this.price,
    this.priceString,
    this.rsSize,
    this.fontSize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ///appText is custom widget for text
        ///you can use it instead of text widget
        ///or using text widget directly
        AppText(
          text: price,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
        ),

        ///this for arabic riyal symbol
        Text(
          '\u200A${String.fromCharCode(0xE900)}',
          style: TextStyle(
            fontSize: rsSize ?? 14,
            fontFamily: 'saudi_riyal',
            color: color,
          ),
        ),
      ],
    );
  }
}