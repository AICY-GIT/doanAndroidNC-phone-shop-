import 'package:flutter/material.dart';
import 'page/favwidget.dart';
import 'page/userwidget.dart';
import 'page/homewidget.dart';
import 'page/category/categorywidget.dart';
import 'page/product/productwidget.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({Key? key}) : super(key: key);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomeWidget(),
    CategoryWidget(),
    ProductWidget(),
    FavWidget(),
    UserWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 20.0), // Add 10dp to the standard toolbar height
          child: Column(
            children: [
              const SizedBox(height: 20), // Add 10dp of space above the AppBar
              AppBar(
                actions: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add your shopping cart action here
                    },
                    icon: const Icon(Icons.shopping_cart,size:40,),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[800], // Set background color to darker gray
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: Colors.black), // Set icon color to black
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined,
                  color: Colors.black), // Set icon color to black
              label: 'Category',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list,
                  color: Colors.black), // Set icon color to black
              label: 'Product',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline,
                  color: Colors.black), // Set icon color to black
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline,
                  color: Colors.black), // Set icon color to black
              label: 'User',
              
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 10, 10, 10),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
