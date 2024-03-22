import 'package:buoi4/conf/const.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "User page",
        style: titleStyle,
      ),
    );
  }
}