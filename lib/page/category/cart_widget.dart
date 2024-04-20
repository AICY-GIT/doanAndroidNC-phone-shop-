import 'package:buoi4/page/product/checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        // Lấy ID người dùng đang đăng nhập
        final uid = FirebaseAuth.instance.currentUser?.uid;

        // Kiểm tra nếu không có người dùng đăng nhập
        if (uid == null) {
            return Center(
                child: Text('Please log in to view your cart.'),
            );
        }

        // Tạo tham chiếu đến giỏ hàng của người dùng
        final DatabaseReference cartRef = FirebaseDatabase.instance
            .ref()
            .child('carts')
            .child(uid);

        // Sử dụng StreamBuilder để lắng nghe thay đổi dữ liệu trong giỏ hàng
        return StreamBuilder<DatabaseEvent>(
            stream: cartRef.onValue,
            builder: (context, snapshot) {
                // Kiểm tra trạng thái kết nối
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Kiểm tra dữ liệu sản phẩm
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return Center(child: Text('No items in your cart.'));
                }

                // Lấy dữ liệu giỏ hàng và ép kiểu an toàn
                final cartData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                // Lọc các sản phẩm có thuộc tính state là "wait"
                final List<Map<String, dynamic>> waitProducts = [];
                num totalCost = 0; // Biến để tính tổng giá của tất cả các sản phẩm

                if (cartData != null) {
                    cartData.forEach((key, value) {
                        final productMap = value as Map<dynamic, dynamic>;
                        final state = productMap['state'] as String?;
                        if (state == 'wait') {
                            // Chuyển đổi kiểu dữ liệu từ Map<dynamic, dynamic> thành Map<String, dynamic>
                            final product = productMap.map(
                                (k, v) => MapEntry<String, dynamic>(k.toString(), v),
                            );
                            product['key'] = key; // Lưu khóa của sản phẩm để sử dụng sau này
                            waitProducts.add(product);

                            // Tính tổng tiền từng sản phẩm bằng cách nhân giá với số lượng
                            final price = product['price'] as num?;
                            final quantity = product['quantity'] as int?;
                            if (price != null && quantity != null) {
                                final productTotal = price * quantity;
                                totalCost += productTotal;
                            }
                        }
                    });
                }

                // Kiểm tra nếu không có sản phẩm nào thỏa điều kiện
                if (waitProducts.isEmpty) {
                    return Center(child: Text('No items in your cart with state "wait".'));
                }

                // Hiển thị danh sách các sản phẩm và tổng giá của tất cả các sản phẩm trong giao diện
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Expanded(
                            child: ListView.builder(
                                itemCount: waitProducts.length,
                                itemBuilder: (context, index) {
                                    final product = waitProducts[index];
                                    final name = product['name'] as String?;
                                    final price = product['price'] as num?;
                                    final quantity = product['quantity'] as int? ?? 1; // Số lượng sản phẩm, mặc định là 1
                                    final imageUrl = product['imageURL'] as String?;
                                    final productKey = product['key'] as String; // Lấy khóa của sản phẩm

                                    return Card(
                                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Đặt margin cho Card
                                        child: ListTile(
                                            leading: Image.network(
                                                imageUrl ?? '',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.error);
                                                },
                                            ),
                                            title: Text(name ?? 'No name'),
                                            subtitle: Text('\$${price?.toStringAsFixed(2)} x $quantity'),
                                            trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    // Nút giảm số lượng
                                                    IconButton(
                                                        icon: Icon(Icons.remove),
                                                        onPressed: () {
                                                            // Giảm số lượng sản phẩm
                                                            if (quantity > 1) {
                                                                cartRef
                                                                    .child(productKey)
                                                                    .child('quantity')
                                                                    .set(quantity - 1);
                                                            }
                                                        },
                                                    ),
                                                    // Hiển thị số lượng sản phẩm
                                                    Text(quantity.toString()),
                                                    // Nút tăng số lượng
                                                    IconButton(
                                                        icon: Icon(Icons.add),
                                                        onPressed: () {
                                                            // Tăng số lượng sản phẩm
                                                            cartRef
                                                                .child(productKey)
                                                                .child('quantity')
                                                                .set(quantity + 1);
                                                        },
                                                    ),
                                                ],
                                            ),
                                        ),
                                    );
                                },
                            ),
                        ),
                       // Hiển thị ô tổng giá và nút thanh toán cạnh nhau
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Card(
                                color: Colors.grey[200], // Màu nền của Card
                                shape: RoundedRectangleBorder( // Tạo bo tròn cho Card
                                    borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(15), // Khoảng cách nội dung bên trong Card
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Sắp xếp tổng giá và nút thanh toán cách nhau
                                        children: [
                                            // Ô tổng giá
                                            Text(
                                                'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                ),
                                            ),
                                            // Nút thanh toán
                                            ElevatedButton(
                                                onPressed: () {
                                                    // Chuyển hướng đến trang CheckoutPage
                                                 Navigator.pushNamed(context, CheckoutPage.routeName);
                                                },
                                                child: Text('Checkout'),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue, // Màu nền của nút
                                                    shape: RoundedRectangleBorder( // Bo tròn góc của nút
                                                        borderRadius: BorderRadius.circular(10),
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ),
                    ],
                );
            },
        );
    }
}