import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:buoi4/page/admin/editproducts.dart';

class ListProducts extends StatelessWidget {
    static const routeName = '/listproducts';

    const ListProducts({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('List Products'),
                    bottom: const TabBar(
                        tabs: [
                            Tab(text: 'Phone'),
                            Tab(text: 'Earphone'),
                        ],
                    ),
                ),
                body: TabBarView(
                    children: [
                        ProductsList(group: 'phone'),
                        ProductsList(group: 'earphone'),
                    ],
                ),
            ),
        );
    }
}

class ProductsList extends StatelessWidget {
    final String group;

    const ProductsList({required this.group, Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        // Tạo đường dẫn dựa trên nhóm (group)
        final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('products/$group');

        return StreamBuilder<DatabaseEvent>(
            stream: databaseRef.onValue,
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Kiểm tra dữ liệu sản phẩm
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text('No products found.'));
                }

                // Lấy danh sách sản phẩm từ dữ liệu
                final Map<dynamic, dynamic> productsData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>;

                // Hiển thị danh sách sản phẩm
                return ListView.builder(
                    padding: const EdgeInsets.all(12), // Thêm khoảng cách bên ngoài cho danh sách
                    itemCount: productsData.length,
                    itemBuilder: (context, index) {
                        final productKey = productsData.keys.elementAt(index);
                        final product = productsData[productKey];

                        // Lấy các thuộc tính của sản phẩm
                        final imageUrl = product['imageURL'];
                        final name = product['phoneName'] ?? product['name'];
                        final price = product['price'];

                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8), // Thêm khoảng cách giữa các sản phẩm
                            child: Slidable(
                                key: ValueKey(productKey),
                                endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                        SlidableAction(
                                            onPressed: (context) {
                                                // Xóa sản phẩm từ Firebase Database
                                                databaseRef.child(productKey).remove();
                                            },
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                        ),
                                    ],
                                ),
                                child: Card(
                                    elevation: 4, // Tạo hiệu ứng nổi cho sản phẩm
                                    shape: RoundedRectangleBorder( // Tạo góc bo tròn
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                        contentPadding: const EdgeInsets.all(8), // Thêm khoảng cách bên trong
                                        leading: Image.network(
                                            imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                        ),
                                        title: Text(name),
                                        subtitle: Text('\$${price.toString()}'),
                                        trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                                // Chuyển hướng đến trang EditProductsScreen với productKey và group
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => EditProductsScreen(
                                                            productKey: productKey,
                                                            group: group,
                                                        ),
                                                    ),
                                                );
                                            },
                                        ),
                                    ),
                                ),
                            ),
                        );
                    },
                );
            },
        );
    }
}
