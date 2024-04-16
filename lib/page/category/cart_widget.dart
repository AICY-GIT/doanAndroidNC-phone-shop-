// ignore_for_file: no_logic_in_create_state

import 'package:buoi4/models/constants.dart';
import 'package:buoi4/models/phones.dart';
import 'package:buoi4/page/product/phone_widget.dart';
import 'package:flutter/material.dart';

class CartWidget extends StatefulWidget {
 final List<Phone> addedToCartPhones;
  const CartWidget({Key? key, required this.addedToCartPhones}) : super(key: key);

  @override
  State<CartWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartWidget> {
   @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: widget.addedToCartPhones.isEmpty
          ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: Image.asset('assets/images/add-cart.png'),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Your Cart is Empty',
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
        height: size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: widget.addedToCartPhones.length,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return PhoneWidget(
                        index: index, phoneList: widget.addedToCartPhones);
                  }),
            ),
            Column(
              children: [
                const Divider(thickness: 1.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Totals',style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w300,
                    ),
                    ),
                      Text(r'$65', style: TextStyle(
                        fontSize: 24.0,
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
