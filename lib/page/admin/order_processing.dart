import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderProcessingPage extends StatefulWidget {
    final String userId;
    final List<Map<String, dynamic>> newOrders;
    final List<Map<String, dynamic>> oldOrders;

    OrderProcessingPage({required this.userId, required this.newOrders, required this.oldOrders});

    @override
    _OrderProcessingPageState createState() => _OrderProcessingPageState();
}

class _OrderProcessingPageState extends State<OrderProcessingPage> {
    // Từ điển để lưu trữ trạng thái thay đổi của sản phẩm
    Map<String, Map<String, String>> changedProductStates = {};

    // Hàm để cập nhật trạng thái của sản phẩm trong Firebase
    Future<void> _updateProductStateInFirebase(String orderId, String productKey, String newState) async {
        final databaseRef = FirebaseDatabase.instance.reference();

        // Tạo đường dẫn đến sản phẩm cần cập nhật
        final productPath = databaseRef.child('orders')
            .child(widget.userId)
            .child(orderId)
            .child('waitProducts')
            .orderByChild('key')
            .equalTo(productKey);

        // Lấy dữ liệu sản phẩm cụ thể từ `orderByChild`
        final event = await productPath.once();

        // Lấy DataSnapshot từ sự kiện
        final snapshot = event.snapshot;

        // Kiểm tra nếu sản phẩm tồn tại trong `waitProducts`
        if (snapshot.exists) {
            // Lấy đường dẫn của sản phẩm
            final productRef = snapshot.children.first.ref;

            // Cập nhật trạng thái của sản phẩm trong cơ sở dữ liệu Firebase
            await productRef.child('state').set(newState);
        }
    }

    // Hàm để cập nhật trạng thái sản phẩm lên Firebase từ danh sách thay đổi
    Future<void> _updateChangedProductStates() async {
        for (var orderId in changedProductStates.keys) {
            var products = changedProductStates[orderId];
            for (var productKey in products!.keys) {
                var newState = products[productKey];
                if (newState != null) {
                    await _updateProductStateInFirebase(orderId, productKey, newState);
                }
            }

            // Kiểm tra và cập nhật trạng thái đơn hàng nếu cần thiết
            await checkAndUpdateOrderStatus(orderId);
        }

        // Làm trống danh sách thay đổi sau khi cập nhật
        setState(() {
            changedProductStates.clear();
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đơn hàng đã được xử lý thành công!'))
        );
    }

    // Hàm kiểm tra trạng thái đơn hàng và cập nhật nếu cần
    Future<void> checkAndUpdateOrderStatus(String orderId) async {
        final databaseRef = FirebaseDatabase.instance.reference();
        final orderPath = databaseRef.child('orders')
            .child(widget.userId)
            .child(orderId);

        // Lấy thông tin đơn hàng từ cơ sở dữ liệu
        final event = await orderPath.once();
        final orderSnapshot = event.snapshot;

        // Kiểm tra trạng thái của đơn hàng
        if (orderSnapshot.exists) {
            final products = orderSnapshot.child('waitProducts').value as List<dynamic>;
            bool allCanceledOrReceived = true;
            bool hasCanceled = false;
            bool hasReceived = false;

            // Kiểm tra trạng thái của các sản phẩm trong đơn hàng
            for (var product in products) {
                final productState = product['state'] as String;

                // Kiểm tra trạng thái sản phẩm
                if (productState != 'canceled' && productState != 'received') {
                    allCanceledOrReceived = false;
                    break;
                }

                if (productState == 'canceled') {
                    hasCanceled = true;
                }

                if (productState == 'received') {
                    hasReceived = true;
                }
            }

            // Nếu tất cả trạng thái sản phẩm là `canceled` hoặc `received`, hoặc nếu có cả hai trạng thái
            if (allCanceledOrReceived || (hasCanceled && hasReceived)) {
                // Cập nhật trạng thái của đơn hàng từ `not_yet_approved` thành `approved`
                await orderPath.child('status').set('approved');

                // Hiển thị thông báo thành công khi cập nhật trạng thái đơn hàng
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đơn hàng đã được xử lý thành công!'))
                );
            }
        }
    }

    // Hàm để xác định danh sách trạng thái có thể chọn dựa trên trạng thái hiện tại
    List<String> getAvailableStates(String currentState) {
        switch (currentState) {
            case 'wait':
                // Khi trạng thái hiện tại là 'wait', hiển thị danh sách chọn là 'wait', 'confirmed', 'canceled'
                return ['wait', 'confirmed', 'canceled'];
            case 'confirmed':
                // Khi trạng thái hiện tại là 'confirmed', hiển thị danh sách chọn là 'confirmed', 'delivered', 'canceled'
                return ['confirmed', 'delivered', 'canceled'];
            case 'delivered':
                // Khi trạng thái hiện tại là 'delivered', hiển thị danh sách chọn là 'delivered', 'received'
                return ['delivered', 'received'];
            case 'received':
                // Khi trạng thái hiện tại là 'received', hiển thị danh sách chọn là 'received'
                return ['received'];
            case 'canceled':
                // Khi trạng thái hiện tại là 'canceled', hiển thị danh sách chọn là 'canceled'
                return ['canceled'];
            default:
                // Trường hợp mặc định nếu trạng thái hiện tại không khớp với bất kỳ trường hợp nào ở trên
                return [];
        }
    }

    @override
    Widget build(BuildContext context) {
        return DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                    title: Text('Xử lý đơn hàng'),
                    bottom: TabBar(
                        tabs: [
                            Tab(text: 'Đơn hàng mới'),
                            Tab(text: 'Đơn hàng cũ'),
                        ],
                    ),
                ),
                body: TabBarView(
                    children: [
                        // Tab 1: Đơn hàng mới
                        ListView.builder(
                            itemCount: widget.newOrders.length,
                            itemBuilder: (context, index) {
                                final order = widget.newOrders[index];
                                final status = order['status'] as String?;
                                final products = order['waitProducts'] as List<dynamic>?;
                                final totalOrderCost = order['totalOrderCost'] as num?;

                                return Card(
                                    color: Colors.lightBlueAccent,
                                    shadowColor: Colors.blueGrey,
                                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'Order ID: ${order['order_id']}',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text('Ngày: ${order['orderDate']}'),
                                                Text('Trạng thái: $status'),
                                                Text('Tổng chi phí đơn hàng: \$${totalOrderCost?.toStringAsFixed(2)}'),
                                                const SizedBox(height: 8),
                                                Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                if (products != null && products.isNotEmpty)
                                                    Card(
                                                        color: Colors.white,
                                                        shadowColor: Colors.blueGrey,
                                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                                        child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: products.map((product) {
                                                                    return Card(
                                                                        color: Colors.grey[100],
                                                                        shadowColor: Colors.blueGrey,
                                                                        margin: const EdgeInsets.only(top: 5),
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                    Row(
                                                                                        children: [
                                                                                            Image.network(
                                                                                                product['imageURL'] as String,
                                                                                                width: 50,
                                                                                                height: 50,
                                                                                                fit: BoxFit.cover,
                                                                                                errorBuilder: (context, error, stackTrace) {
                                                                                                    return const Icon(Icons.error);
                                                                                                },
                                                                                            ),
                                                                                            const SizedBox(width: 10),
                                                                                            Expanded(
                                                                                                child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                        Text(
                                                                                                            product['name'] as String,
                                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                        ),
                                                                                                        Text('Giá: \$${product['price']}'),
                                                                                                        Text('Số lượng: ${product['quantity']}'),
                                                                                                        Text('Màu sắc: ${product['color']}'),
                                                                                                        Text('Dung lượng pin: ${product['batteryCapacity']} mAh'),
                                                                                                        Text('Kích thước: ${product['size']}'),
                                                                                                        Text('Mô tả: ${product['description']}'),
                                                                                                        // Dropdown để thay đổi trạng thái sản phẩm trong UI
                                                                                                        Row(
                                                                                                            children: [
                                                                                                                Text('Trạng thái: '),
                                                                                                                DropdownButton<String>(
                                                                                                                    value: product['state'] as String?,
                                                                                                                    items: getAvailableStates(product['state'] as String).map((String state) {
                                                                                                                        return DropdownMenuItem<String>(
                                                                                                                            value: state,
                                                                                                                            child: Text(state),
                                                                                                                        );
                                                                                                                    }).toList(),
                                                                                                                    onChanged: (newState) {
                                                                                                                        if (newState != null) {
                                                                                                                            // Cập nhật trạng thái cục bộ trong UI
                                                                                                                            setState(() {
                                                                                                                                product['state'] = newState;
                                                                                                                            });

                                                                                                                            // Lưu trạng thái thay đổi vào từ điển
                                                                                                                            if (!changedProductStates.containsKey(order['order_id'])) {
                                                                                                                                changedProductStates[order['order_id']] = {};
                                                                                                                            }
                                                                                                                            changedProductStates[order['order_id']]![product['key']] = newState;
                                                                                                                        }
                                                                                                                    },
                                                                                                                ),
                                                                                                            ],
                                                                                                        ),
                                                                                                    ],
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ],
                                                                            ),
                                                                        ),
                                                                    );
                                                                }).toList(),
                                                            ),
                                                        ),
                                                    ),
                                                // Button cập nhật trạng thái lên Firebase
                                                ElevatedButton(
                                                    onPressed: () async {
                                                        await _updateChangedProductStates();
                                                        // Hiển thị thông báo cập nhật thành công
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Đơn hàng đã được xử lý thành công!'))
                                                        );
                                                    },
                                                    child: Text('Cập nhật trạng thái đơn hàng'),
                                                ),
                                            ],
                                        ),
                                    ),
                                );
                            },
                        ),
                        // Tab 2: Đơn hàng cũ
                        ListView.builder(
                            itemCount: widget.oldOrders.length,
                            itemBuilder: (context, index) {
                                final order = widget.oldOrders[index];
                                final status = order['status'] as String?;
                                final products = order['waitProducts'] as List<dynamic>?;
                                final totalOrderCost = order['totalOrderCost'] as num?;

                                return Card(
                                    color: Colors.lightBlueAccent,
                                    shadowColor: Colors.blueGrey,
                                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'Order ID: ${order['order_id']}',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text('Ngày: ${order['orderDate']}'),
                                                Text('Trạng thái: $status'),
                                                Text('Tổng chi phí đơn hàng: \$${totalOrderCost?.toStringAsFixed(2)}'),
                                                const SizedBox(height: 8),
                                                Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                if (products != null && products.isNotEmpty)
                                                    Card(
                                                        color: Colors.white,
                                                        shadowColor: Colors.blueGrey,
                                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                                        child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: products.map((product) {
                                                                    return Card(
                                                                        color: Colors.grey[100],
                                                                        shadowColor: Colors.blueGrey,
                                                                        margin: const EdgeInsets.only(top: 5),
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                    Row(
                                                                                        children: [
                                                                                            Image.network(
                                                                                                product['imageURL'] as String,
                                                                                                width: 50,
                                                                                                height: 50,
                                                                                                fit: BoxFit.cover,
                                                                                                errorBuilder: (context, error, stackTrace) {
                                                                                                    return const Icon(Icons.error);
                                                                                                },
                                                                                            ),
                                                                                            const SizedBox(width: 10),
                                                                                            Expanded(
                                                                                                child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                        Text(
                                                                                                            product['name'] as String,
                                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                                        ),
                                                                                                        Text('Giá: \$${product['price']}'),
                                                                                                        Text('Số lượng: ${product['quantity']}'),
                                                                                                        Text('Màu sắc: ${product['color']}'),
                                                                                                        Text('Dung lượng pin: ${product['batteryCapacity']} mAh'),
                                                                                                        Text('Kích thước: ${product['size']}'),
                                                                                                        Text('Mô tả: ${product['description']}'),
                                                                                                        Row(
                                                                                                            children: [
                                                                                                                Text('Trạng thái: '),
                                                                                                                DropdownButton<String>(
                                                                                                                    value: product['state'] as String?,
                                                                                                                    items: getAvailableStates(product['state'] as String).map((String state) {
                                                                                                                        return DropdownMenuItem<String>(
                                                                                                                            value: state,
                                                                                                                            child: Text(state),
                                                                                                                        );
                                                                                                                    }).toList(),
                                                                                                                    onChanged: (newState) {
                                                                                                                        if (newState != null) {
                                                                                                                            // Cập nhật trạng thái cục bộ trong UI
                                                                                                                            setState(() {
                                                                                                                                product['state'] = newState;
                                                                                                                            });

                                                                                                                            // Lưu trạng thái thay đổi vào từ điển
                                                                                                                            if (!changedProductStates.containsKey(order['order_id'])) {
                                                                                                                                changedProductStates[order['order_id']] = {};
                                                                                                                            }
                                                                                                                            changedProductStates[order['order_id']]![product['key']] = newState;
                                                                                                                        }
                                                                                                                    },
                                                                                                                ),
                                                                                                            ],
                                                                                                        ),
                                                                                                    ],
                                                                                                ),
                                                                                            ),
                                                                                        ],
                                                                                    ),
                                                                                ],
                                                                            ),
                                                                        ),
                                                                    );
                                                                }).toList(),
                                                            ),
                                                        ),
                                                    ),
                                                // Button cập nhật trạng thái lên Firebase
                                                ElevatedButton(
                                                    onPressed: () async {
                                                        await _updateChangedProductStates();
                                                        // Hiển thị thông báo cập nhật thành công
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Trạng thái đơn hàng đã được cập nhật thành công!'))
                                                        );
                                                    },
                                                    child: Text('Cập nhật trạng thái đơn hàng'),
                                                ),
                                            ],
                                        ),
                                    ),
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}
