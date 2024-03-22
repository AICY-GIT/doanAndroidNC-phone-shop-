import 'package:buoi4/data/model/productmodel.dart';
import 'package:flutter/material.dart';
import '../../conf/const.dart';
import 'package:intl/intl.dart';
Widget itemGirdView(Product productModel) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.grey.shade200),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(
          pro_img + productModel.img!,
          height: 80,
          width: 80,
        ),
        const SizedBox(
          width: 30,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productModel.name ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              "Price :${NumberFormat('###,###.###').format(productModel.price)}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              productModel.des!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    ),
  );
}
