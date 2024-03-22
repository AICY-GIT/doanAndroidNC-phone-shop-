import 'package:buoi4/conf/const.dart';
import 'package:flutter/material.dart';

class FavWidget extends StatelessWidget {
  const FavWidget({super.key});

  @override
  Widget build(BuildContext context) {
   return const Center(
      child: Text(
        "Fav page",
        style: titleStyle,
      ),
    );
  }
}