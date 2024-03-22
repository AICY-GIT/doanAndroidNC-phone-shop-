import 'package:buoi4/data/model/productmodel.dart';
import 'package:buoi4/page/product/productbody.dart';
import 'package:flutter/material.dart';
import '../../conf/const.dart';
import 'package:intl/intl.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({Key? key}) : super(key: key);

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  List<Product> lstProduct = [];

  @override
  void initState() {
    super.initState();
    lstProduct = createDataList(10);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: lstProduct.length,
      itemBuilder: (context, index) {
        return itemGirdView(lstProduct[index]);
      },
    );
  }

  List<Product> createDataList(int amount) {
    List<Product> lstProduct = [];
    for (int i = 1; i <= amount; i++) {
      lstProduct.add(Product(
          i, "SmartPhone new version $i", i * 10000, "img_$i.jpg", "Iphone"));
    }
    return lstProduct;
  }
}


