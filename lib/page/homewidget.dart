import 'package:buoi4/page/product/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeWidget extends StatefulWidget {
  static const routeName = '/home';

  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('products');

  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
                FocusScope.of(context).unfocus(); // Remove focus from TextField
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Thêm banner tự động chạy phía trên thanh TabBar
            _buildBanner(),
            // Hiển thị thanh TabBar
            const TabBar(
              tabs: [
                Tab(text: 'Phone'),
                Tab(text: 'Earphone'),
              ],
            ),
            // Sử dụng Expanded để cho phép TabBarView mở rộng để sử dụng không gian còn lại
            Expanded(
              child: TabBarView(
                children: [
                  ProductsList(
                      group: 'phone',
                      databaseRef: _databaseRef,
                      searchQuery: _searchController.text),
                  ProductsList(
                      group: 'earphone',
                      databaseRef: _databaseRef,
                      searchQuery: _searchController.text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức để tạo banner chạy tự động với 4 ảnh
  Widget _buildBanner() {
    // Danh sách tên tệp ảnh trong thư mục assets
    final List<String> imageFiles = [
      'assets/phoneimages/banner1.png',
      'assets/phoneimages/banner2.png',
      'assets/phoneimages/banner3.png',
      'assets/phoneimages/banner4.png',
    ];

    // Sử dụng CarouselSlider để hiển thị banner chạy tự động
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        aspectRatio: 16 / 9,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        enableInfiniteScroll: true,
        viewportFraction: 0.8,
      ),
      items: imageFiles.map((imageFile) {
        return Builder(
          builder: (context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageFile),
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class ProductsList extends StatelessWidget {
  final String group;
  final DatabaseReference databaseRef;
  final String searchQuery;

  const ProductsList({
    required this.group,
    required this.databaseRef,
    required this.searchQuery,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ref = databaseRef.child(group);

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text('No products found.'));
        }

        final Map<dynamic, dynamic> productsData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>;

        // Filter products based on search query
        final filteredProducts = productsData.entries.where((entry) {
          final product = entry.value;
          final name = product['phoneName'] ?? product['name'];
          return name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final entry = filteredProducts[index];
            final productKey = entry.key;
            final product = entry.value;

            final imageUrl = product['imageURL'];
            final name = product['phoneName'] ?? product['name'];
            final price = product['price'];
            final category = product['category'];

            return GestureDetector(
              onTap: () {
                print('Sản phẩm được nhấp vào:');
                print('ID: $productKey');
                print('Thông tin sản phẩm: $product');
                // Điều hướng đến DetailPage và truyền ID sản phẩm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(productId: productKey, group: group),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name),
                          Text('\$${price}'),
                          Text('Category: $category'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
