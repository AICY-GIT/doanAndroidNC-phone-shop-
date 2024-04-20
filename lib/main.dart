// ignore_for_file: prefer_const_constructors

import 'package:buoi4/page/admin/HomeAdmin.dart';
import 'package:buoi4/page/admin/edit_upload_product_form.dart';
import 'package:buoi4/page/admin/editproducts.dart';
import 'package:buoi4/page/admin/listproduct.dart';
import 'package:buoi4/page/homewidget.dart';
import 'package:buoi4/page/product/checkout.dart';
import 'package:buoi4/page/user/Loginwidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buoi4/page/admin/providers/theme_provider.dart';
import 'package:buoi4/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        // Các Provider khác nếu cần
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginWidget(),
      routes: {
                EditOrUploadProductScreen.routeName: (context) => const EditOrUploadProductScreen(),
                HomeAdmin.routeName: (context) => const HomeAdmin(),
                ListProducts.routeName: (context) => const ListProducts(),
                EditProductsScreen.routeName: (context) => const EditProductsScreen( productKey: '', group: '',),
                HomeWidget.routeName:(context) => HomeWidget(),
                CheckoutPage.routeName: (context) =>  CheckoutPage(),
                                RootPage.routeName:(context) => RootPage(),


            },
    );
  }
}
