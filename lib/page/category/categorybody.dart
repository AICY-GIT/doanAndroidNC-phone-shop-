import 'package:flutter/material.dart';
import '../../../data/model/categorymodel.dart';
import '../../conf/const.dart';

Widget itemCateView(Category itemcate) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: const BoxDecoration(color: Color.fromARGB(255, 139, 171, 231)),
    child: Container(
      width: 150,
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)
          // Adjust the radius as needed
          ),
      child: Image.asset(
        urlimg + itemcate.img!,
        fit: BoxFit.cover,
      ),
    ),
  );
}
