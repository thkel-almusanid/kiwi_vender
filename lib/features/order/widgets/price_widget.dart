import 'package:flutter/material.dart';
import 'package:sixam_mart_store/util/styles.dart';

class PriceWidget extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;
  const PriceWidget({super.key, required this.title, required this.value, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Text(title, style: cairoRegular.copyWith(fontSize: fontSize,overflow: TextOverflow.ellipsis,),maxLines: 2,)),
      Text(value, style: cairoMedium.copyWith(fontSize: fontSize)),
    ]);
  }
}
