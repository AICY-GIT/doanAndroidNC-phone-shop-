import 'package:buoi4/models/constants.dart';
import 'package:buoi4/models/phone_widget.dart';
import 'package:buoi4/models/phones.dart';
import 'package:flutter/material.dart';

class FavWidget extends StatefulWidget {
  final List<Phone> favoritedPhone;
  const FavWidget({Key? key, required this.favoritedPhone})
      : super(key: key);

  @override
  State<FavWidget> createState() => _FavoritePageState();
}
class _FavoritePageState extends State<FavWidget> {
  @override
 Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: widget.favoritedPhone.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: Image.asset('assets/images/favorited.png'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Your favorited Plants',
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
              height: size.height * .5,
            //   child: ListView.builder(
            //       itemCount: widget.favoritedPhone.length,
            //       scrollDirection: Axis.vertical,
            //       physics: const BouncingScrollPhysics(),
            //       // itemBuilder: (BuildContext context, int index) {
            //       //   return PhoneWidget(
            //       //       index: index, phoneList: widget.favoritedPhone);
            //       // }),
            ),
    );
  }
}