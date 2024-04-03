import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buoi4/data/model/productmodel.dart';
import 'package:buoi4/page/product/productbody.dart';
import '../../conf/const.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({Key? key}) : super(key: key);

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  List<Product> lstProduct = [];
  List<Product> lstEarPhone = [];
  List<Product> lstAccessory = [];

  @override
  void initState() {
    super.initState();
    lstProduct = createDataList(10);
    lstEarPhone = createDataListEarPhone(10);
    lstAccessory = createDataAccessory(10);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(245, 241, 228, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 50, //chieu cao
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, //so luong trong cate
              itemBuilder: (context, index) {
                String categoryName = '';
                List<Product> productList = [];
                if (index == 0) {
                  categoryName = 'Phone Products';
                  productList = lstEarPhone;
                } else if (index == 1) {
                  categoryName = 'EarPhone Products';
                  productList = lstProduct;
                } else if (index == 2) {
                  categoryName = 'Accessory Products';
                  productList = lstAccessory;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      //them hanh dong loc
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(categoryName),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            //tao danh muc san pham
            child: ListView.builder(
              itemCount: 3, // so luong danh muc san pham hien
              itemBuilder: (context, index) {
                String categoryName = '';
                List<Product> productList = [];

                if (index == 0) {
                  categoryName = 'Phone Products';
                  productList = lstEarPhone;
                } else if (index == 1) {
                  categoryName = 'EarPhone Products';
                  productList = lstProduct;
                } else if (index == 2) {
                  categoryName = 'Accessory Products';
                  productList = lstAccessory;
                }
                return _buildProductCategory(categoryName, productList);
              },
            ),
          ),
        ],
      ),
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

  List<Product> createDataListEarPhone(int amount) {
    List<Product> lstProduct = [];
    for (int i = 1; i <= amount; i++) {
      lstProduct.add(Product(
          i, "EarPhone new version $i", i * 10000, "img_$i.jpg", "EarPhone"));
    }
    return lstProduct;
  }

  List<Product> createDataAccessory(int amount) {
    List<Product> lstProduct = [];
    for (int i = 1; i <= amount; i++) {
      lstProduct.add(
          Product(i, "Accessory $i", i * 10000, "img_$i.jpg", "Accessory"));
    }
    return lstProduct;
  }
}

Widget _buildProductCategory(String categoryName, List<Product> productList) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          categoryName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(
        height: 250, // Adjust the height of each product section
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: productList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: itemGridView(productList[index]),
            );
          },
        ),
      ),
    ],
  );
}
