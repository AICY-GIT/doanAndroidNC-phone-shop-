import 'package:buoi4/page/admin/widgets/subtitle_text.dart';
import 'package:flutter/material.dart';

class DashboardButtonsWidget extends StatelessWidget {
  const DashboardButtonsWidget(
      {super.key,
      required this.title,
      required this.imagePath,
      required this.onPressed});

  final String title, imagePath;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 65,
              width: 65,
            ),
            const SizedBox(
              height: 15,
            ),
            SubtitleTextWidget(
              label: title,
              fontSize: 18,
            )
          ],
        ),
      ),
    );
  }
}
