import 'package:buoi4/conf/const.dart';
import 'package:flutter/material.dart';
import 'loginwidget.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      color: const Color.fromRGBO(245, 241, 228, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Hồ sơ cá nhân",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50, // Adjust the size of the avatar
                  backgroundImage: NetworkImage(
                      'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimage.petmd.com%2Ffiles%2Fstyles%2F863x625%2Fpublic%2FCANS_dogsmiling_379727605.jpg%3Fw%3D1920%26q%3D75&f=1&nofb=1&ipt=93a5fdeddc6576a918692db73e5a090277b76e9127e4c6e9e96a324cdc215c6e&ipo=images'), // Replace with your image URL
                ),
                SizedBox(width: 20),
                Text(
                  "Username",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            color: Colors.grey,
            thickness: 10,
          ),
          const SizedBox(
            height: 20,
          ),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.email,
                  color: Colors.black,
                  size: 30,
                ), // Email icon
              ),
              Text('example@example.com',
                  style: TextStyle(
                      color: Colors.black, fontSize: 20)), // Email text
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            indent: 30,
            endIndent: 30,
          ),
          const Row(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.phone,
                  color: Colors.black,
                  size: 30,
                ), // Phone icon
              ),
              Text('123-456-7890',
                  style: TextStyle(color: Colors.black, fontSize: 20)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            indent: 30,
            endIndent: 30,
          ),
          const Row(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.black,
                  size: 30,
                ), // Phone icon
              ),
              Text('Shopping cart',
                  style: TextStyle(color: Colors.black, fontSize: 20)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            indent: 30,
            endIndent: 30,
          ),
          const Row(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.bookmark,
                  color: Colors.black,
                  size: 30,
                ), // Phone icon
              ),
              Text('Order',
                  style: TextStyle(color: Colors.black, fontSize: 20)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            indent: 30,
            endIndent: 30,
          ),
          const Row(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.mode_edit,
                  color: Colors.black,
                  size: 30,
                ), // Phone icon
              ),
              Text('Change User info',
                  style: TextStyle(color: Colors.black, fontSize: 20)),
            ],
          ),
          
          const Divider(
            indent: 30,
            endIndent: 30,
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginWidget(), // Navigate to the LoginWidget
          ),
        );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 30, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  "Logout",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
