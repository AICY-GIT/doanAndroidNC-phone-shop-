import 'package:buoi4/mainpage.dart';
import 'package:buoi4/page/admin/providers/theme_provider.dart';
import 'package:buoi4/page/admin/screens/dashboard_screen.dart';
import 'package:buoi4/page/admin/screens/edit_upload_product_form.dart';
import 'package:buoi4/page/admin/screens/inner_screens/orders/orders_screen.dart';
import 'package:buoi4/page/admin/screens/search_screen.dart';
import 'package:buoi4/root_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
      home: RootPage(),
      routes: {
        OrdersScreenFree.routeName: (context) => const OrdersScreenFree(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        EditOrUploadProductScreen.routeName: (context) => const EditOrUploadProductScreen(),
      },
    );
  }
}

