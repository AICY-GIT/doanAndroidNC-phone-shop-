
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:buoi4/models/constants.dart';
import 'package:buoi4/models/phones.dart';
import 'package:buoi4/page/category/cart_widget.dart';
import 'package:buoi4/page/favwidget.dart';
import 'package:buoi4/page/homewidget.dart';
import 'package:buoi4/page/userwidget.dart';
import 'package:flutter/material.dart';
import 'package:buoi4/page/product/odersstatus.dart';
import 'package:page_transition/page_transition.dart';

class RootPage extends StatefulWidget {
        static const routeName = '/root';

  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Phone> favorites = [];
  List<Phone> myCart = [];

  int _bottomNavIndex = 0;

  //List of the pages
  List<Widget> _widgetOptions(){
    return [
      const HomeWidget(),
      OrderStatusPage(),
      CartWidget(),
      const UserWidget(),
    ];
  }

  //List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.person,
  ];

  //List of the pages titles
  List<String> titleList = [
    'Home',
    'Favorite',
    'Cart',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     // Text(titleList[_bottomNavIndex], style: TextStyle(
        //     //   color: Constants.blackColor,
        //     //   fontWeight: FontWeight.w500,
        //     //   fontSize: 24,
        //     // ),),
        //     // Icon(Icons.notifications, color: Constants.blackColor, size: 30.0,)
        //   ],
        // ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
     
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: AnimatedBottomNavigationBar(
      //   splashColor: Constants.primaryColor,
      //   activeColor: Constants.primaryColor,
      //   inactiveColor: Colors.black.withOpacity(.5),
      //   icons: iconList,
      //   activeIndex: _bottomNavIndex,
      //   gapLocation: GapLocation.center,
      //   notchSmoothness: NotchSmoothness.softEdge,
      //   onTap: (index){
      //     setState(() {
      //       _bottomNavIndex = index;
      //       final List<Phone> favoritedPhone = Phone.getFavoritedPhone();
      //       final List<Phone> addedToCartPhones = Phone.addedToCartPhones();

      //       favorites = favoritedPhone;
      //       myCart = addedToCartPhones.toSet().toList();
      //     });
      //   }
      // ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shop),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'User',
              ),
            ],
            currentIndex: _bottomNavIndex,
            selectedItemColor: Constants.primaryColor,
            unselectedItemColor: Colors.black.withOpacity(.5),
            onTap: (index) {
              setState(() {
                _bottomNavIndex = index;
                final List<Phone> favoritedPhone = Phone.getFavoritedPhone();
                final List<Phone> addedToCartPhones = Phone.addedToCartPhones();

                favorites = favoritedPhone;
                myCart = addedToCartPhones.toSet().toList();
              });
            },
          ),
        ),
      ),
    );
  }
}
