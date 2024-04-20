// ignore_for_file: prefer_const_constructors

import 'package:buoi4/page/admin/edit_upload_product_form.dart';
import 'package:buoi4/page/admin/listproduct.dart';
import 'package:flutter/material.dart';

class HomeAdmin extends StatelessWidget {
      static const routeName = '/homeadmin';

  const HomeAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Số cột trong lưới
          crossAxisSpacing: 16.0, // Khoảng cách giữa các cột
          mainAxisSpacing: 16.0, // Khoảng cách giữa các hàng
          children: [
            // Khung ô "Add Products"
            _buildAdminCard(
              context,
              title: 'Add Products',
              icon: Icons.add_box,
              onTap: () {
                // Xử lý chuyển hướng đến trang thêm sản phẩm
              Navigator.pushNamed(context, EditOrUploadProductScreen.routeName);
              },
            ),
            // Khung ô "Orders"
            _buildAdminCard(
              context,
              title: 'Orders',
              icon: Icons.list_alt,
              onTap: () {
                // Xử lý chuyển hướng đến trang quản lý đơn hàng
                Navigator.pushNamed(context, '/orders');
              },
            ),
             _buildAdminCard(
              context,
              title: 'Products',
              icon: Icons.list_alt,
              onTap: () {
                // Xử lý chuyển hướng đến trang quản lý đơn hàng
              Navigator.pushNamed(context, ListProducts.routeName);
              },
            ),
            // Khung ô "Users"
            _buildAdminCard(
              context,
              title: 'Users',
              icon: Icons.people,
              onTap: () {
                // Xử lý chuyển hướng đến trang quản lý người dùng
                Navigator.pushNamed(context, '/users');
              },
            ),
            // Khung ô "Revenue"
            _buildAdminCard(
              context,
              title: 'Revenue',
              icon: Icons.attach_money,
              onTap: () {
                // Xử lý chuyển hướng đến trang quản lý doanh thu
                Navigator.pushNamed(context, '/revenue');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tiện ích để tạo một khung ô dành cho quản trị viên
  Widget _buildAdminCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
