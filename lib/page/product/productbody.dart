import 'package:buoi4/data/model/productmodel.dart';
import 'package:flutter/material.dart';
import '../../conf/const.dart';
import 'package:intl/intl.dart';

Widget itemGridView(Product productModel) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      border: Border.all(color: Colors.black),
    ),
    width: 200, // Set a fixed width for each item
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(
          pro_img + productModel.img!,
          height: 100,
          width: 100,
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productModel.name ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              "Price: ${NumberFormat('###,###.###').format(productModel.price)}",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red), // Set the text color to red
            ),
            Text(
              productModel.des!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        OutlinedButton(
          onPressed: () {
            // Add your buy now action here
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: Colors.black), // Set the border color to black
          ),
          child: Text('BUY NOW'),
        ),
      ],
    ),
  );
}
