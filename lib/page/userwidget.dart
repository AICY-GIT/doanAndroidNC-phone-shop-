import 'package:buoi4/models/constants.dart';
import 'package:buoi4/models/profile_widget.dart';
import 'package:buoi4/page/map_page.dart';
import 'package:buoi4/page/product/odersstatus.dart';
import 'package:buoi4/page/user/Loginwidget.dart';
import 'package:buoi4/page/user/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({Key? key}) : super(key: key);

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');
  final FirebaseStorage _storage = FirebaseStorage.instance; // Tham chiếu đến Firebase Storage

  String _fullName = '';
  String _email = '';
  String imagesusser = ''; // URL hình ảnh profile

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData(); // Tải lại dữ liệu khi trang được hiển thị
  }

  void _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      // Lấy dữ liệu người dùng từ Firebase Realtime Database
      DatabaseEvent snapshot = await _userRef.child(uid).once();
      Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _fullName = userData['fullName'] ?? '';
        _email = currentUser.email ?? '';
        imagesusser = userData['imagesusser'] ?? '';
        print('Profile Image URL: $imagesusser'); // Dòng debug
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: size.height,
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ảnh profile và thông tin người dùng
              Container(
                width: 150,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imagesusser.isNotEmpty
                      ? NetworkImage(imagesusser)
                      : AssetImage('assets/phoneimages/user1.png') as ImageProvider<Object>?,
                  onBackgroundImageError: (error, stackTrace) {
                    print('Lỗi tải ảnh: $error');
                  },
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Constants.primaryColor.withOpacity(.5),
                    width: 5.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Hiển thị tên và email của người dùng
              SizedBox(
                width: size.width * .3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _fullName,
                      style: TextStyle(
                        color: Constants.blackColor,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 24,
                      child: Image.asset("assets/phoneimages/verified.png"),
                    ),
                  ],
                ),
              ),
              Text(
                _email,
                style: TextStyle(
                  color: Constants.blackColor.withOpacity(.3),
                ),
              ),
              const SizedBox(height: 30),
              // Các tùy chọn khác của người dùng
              SizedBox(
                height: size.height * .7,
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Điều hướng đến UserProfileWidget
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileWidget(),
                          ),
                        );
                      },
                      child: ProfileWidget(
                        icon: Icons.person,
                        title: 'My Profile',
                      ),
                    ),
                    ProfileWidget(
                      icon: Icons.settings,
                      title: 'Settings',
                    ),
                    ProfileWidget(
                      icon: Icons.notifications,
                      title: 'Notifications',
                    ),
                    GestureDetector(
                      onTap: () {
                        // Điều hướng đến OrderStatusPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderStatusPage(),
                          ),
                        );
                      },
                      child: ProfileWidget(
                        icon: Icons.chat,
                        title: 'Order',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Điều hướng đến mapPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => mapPage(),
                          ),
                        );
                      },
                      child: ProfileWidget(
                        icon: Icons.location_on,
                        title: 'Shop location',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Đăng xuất người dùng và điều hướng đến LoginWidget
                        _auth.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginWidget(),
                          ),
                        );
                      },
                      child: ProfileWidget(
                        icon: Icons.logout,
                        title: 'Log Out',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
