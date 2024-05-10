import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderStatusPage extends StatefulWidget {
    static const routeName = '/order';

    const OrderStatusPage({Key? key}) : super(key: key);

    @override
    _OrderStatusPageState createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> with SingleTickerProviderStateMixin {
    late TabController _tabController;

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 5, vsync: this);
    }

    @override
    void dispose() {
        _tabController.dispose();
        super.dispose();
    }

    // Điều chỉnh TabController khi số lượng tab thay đổi
    void adjustTabController(int newLength) {
        if (newLength != _tabController.length) {
            final newIndex = (_tabController.index >= newLength) ? newLength - 1 : _tabController.index;
            setState(() {
                _tabController.dispose();
                _tabController = TabController(length: newLength, vsync: this, initialIndex: newIndex);
            });
        }
    }

    Future<List<Map<String, dynamic>>> _fetchWaitOrders() async {
        return _fetchOrdersByProductState('wait');
    }

    Future<List<Map<String, dynamic>>> _fetchConfirmedOrders() async {
        return _fetchOrdersByAllProductsState('confirmed');
    }

    Future<List<Map<String, dynamic>>> _fetchDeliveringOrders() async {
        return _fetchOrdersByAllProductsState('delivered');
    }

    // Điều chỉnh hàm để lấy danh sách đơn hàng chứa ít nhất một sản phẩm có trạng thái received
    Future<List<Map<String, dynamic>>> _fetchReceivedOrders() async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
            print('Người dùng chưa đăng nhập.');
            return [];
        }

        final ordersRef = FirebaseDatabase.instance.reference().child('orders').child(uid);
        final snapshot = await ordersRef.once();

        final ordersData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> orders = [];

        if (ordersData != null) {
            ordersData.forEach((orderKey, orderValue) {
                final order = Map<String, dynamic>.from(orderValue as Map<dynamic, dynamic>);
                
                // Kiểm tra danh sách sản phẩm trong đơn hàng
                final products = order['waitProducts'] as List<dynamic>?;
                if (products != null && products.isNotEmpty) {
                    // Kiểm tra nếu có ít nhất một sản phẩm có trạng thái received
                    final hasReceivedProduct = products.any((product) => product['state'] == 'received');
                    
                    // Nếu có ít nhất một sản phẩm có trạng thái received, thêm đơn hàng vào danh sách
                    if (hasReceivedProduct) {
                        orders.add(order);
                    }
                }
            });
        }

        return orders;
    }

    // Điều chỉnh hàm để lấy danh sách đơn hàng chứa ít nhất một sản phẩm có trạng thái canceled
    Future<List<Map<String, dynamic>>> _fetchCancelledOrders() async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
            print('Người dùng chưa đăng nhập.');
            return [];
        }

        final ordersRef = FirebaseDatabase.instance.reference().child('orders').child(uid);
        final snapshot = await ordersRef.once();

        final ordersData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> orders = [];

        if (ordersData != null) {
            ordersData.forEach((orderKey, orderValue) {
                final order = Map<String, dynamic>.from(orderValue as Map<dynamic, dynamic>);
                
                // Kiểm tra danh sách sản phẩm trong đơn hàng
                final products = order['waitProducts'] as List<dynamic>?;
                if (products != null && products.isNotEmpty) {
                    // Kiểm tra nếu có ít nhất một sản phẩm có trạng thái canceled
                    final hasCancelledProduct = products.any((product) => product['state'] == 'canceled');
                    
                    // Nếu có ít nhất một sản phẩm có trạng thái canceled, thêm đơn hàng vào danh sách
                    if (hasCancelledProduct) {
                        orders.add(order);
                    }
                }
            });
        }

        return orders;
    }

    Future<List<Map<String, dynamic>>> _fetchOrdersByProductState(String state) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
            print('Người dùng chưa đăng nhập.');
            return [];
        }

        final ordersRef = FirebaseDatabase.instance.reference().child('orders').child(uid);
        final snapshot = await ordersRef.once();

        final ordersData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> orders = [];

        if (ordersData != null) {
            ordersData.forEach((orderKey, orderValue) {
                final order = Map<String, dynamic>.from(orderValue as Map<dynamic, dynamic>);
                
                final products = order['waitProducts'] as List<dynamic>?;
                if (products != null && products.isNotEmpty) {
                    final hasState = products.any((product) => product['state'] == state);
                    
                    if (hasState) {
                        orders.add(order);
                    }
                }
            });
        }

        return orders;
    }

    Future<List<Map<String, dynamic>>> _fetchOrdersByAllProductsState(String state) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
            print('Người dùng chưa đăng nhập.');
            return [];
        }

        final ordersRef = FirebaseDatabase.instance.reference().child('orders').child(uid);
        final snapshot = await ordersRef.once();

        final ordersData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> orders = [];

        if (ordersData != null) {
            ordersData.forEach((orderKey, orderValue) {
                final order = Map<String, dynamic>.from(orderValue as Map<dynamic, dynamic>);
                
                final products = order['waitProducts'] as List<dynamic>?;
                if (products != null && products.isNotEmpty) {
                    final allInState = products.every((product) => product['state'] == state);
                    
                    if (allInState) {
                        orders.add(order);
                    }
                }
            });
        }

        return orders;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Order Status'),
                bottom: TabBar(
                    controller: _tabController,
                    tabs: [
                        Tab(text: 'Wait for Confirmation'),
                        Tab(text: 'Confirmed'),
                        Tab(text: 'Are Delivering'),
                        Tab(text: 'Received'),
                        Tab(text: 'Cancelled'),
                    ],
                ),
            ),
            body: TabBarView(
                controller: _tabController,
                children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchWaitOrders(),
                        builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                            } else {
                                final waitOrders = snapshot.data ?? [];
                                if (waitOrders.isEmpty) {
                                    return Center(child: Text('Không có đơn hàng chờ xác nhận.'));
                                }
                                return _buildOrderListView(waitOrders);
                            }
                        },
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchConfirmedOrders(),
                        builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                            } else {
                                final confirmedOrders = snapshot.data ?? [];
                                if (confirmedOrders.isEmpty) {
                                    return Center(child: Text('Không có đơn hàng đã xác nhận.'));
                                }
                                return _buildOrderListView(confirmedOrders);
                            }
                        },
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchDeliveringOrders(),
                        builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                            } else {
                                final deliveringOrders = snapshot.data ?? [];
                                if (deliveringOrders.isEmpty) {
                                    return Center(child: Text('Không có đơn hàng đang giao.'));
                                }
                                return _buildOrderListView(deliveringOrders);
                            }
                        },
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchReceivedOrders(),
                        builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                            } else {
                                final receivedOrders = snapshot.data ?? [];
                                if (receivedOrders.isEmpty) {
                                    return Center(child: Text('Không có đơn hàng đã nhận.'));
                                }
                                return _buildOrderListView(receivedOrders);
                            }
                        },
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchCancelledOrders(),
                        builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                            } else {
                                final cancelledOrders = snapshot.data ?? [];
                                if (cancelledOrders.isEmpty) {
                                    return Center(child: Text('Không có đơn hàng đã hủy.'));
                                }
                                return _buildOrderListView(cancelledOrders);
                            }
                        },
                    ),
                ],
            ),
        );
    }

    Widget _buildOrderListView(List<Map<String, dynamic>> orders) {
        return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    'Order ID: ${order['order_id']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                    'Order Date: ${order['orderDate']}',
                                    style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(
                                    'Shipping Cost: \$${order['shippingCost'].toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                    'Total Order Cost: \$${order['totalOrderCost'].toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 10),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: order['waitProducts'].map<Widget>((product) {
                                        final productName = product['name'];
                                        final productQuantity = product['quantity'];
                                        final productPrice = product['price'];
                                        final productImageUrl = product['imageURL'];
                                        final productTotalPrice = productPrice != null ? (productPrice * productQuantity).round() : 0;

                                        return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Row(
                                                children: [
                                                    ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                            productImageUrl ?? '',
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                                return const Icon(Icons.error);
                                                            },
                                                        ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                                Text(
                                                                    productName ?? 'No name',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                ),
                                                                Text(
                                                                    'Quantity: $productQuantity\nPrice: \$${productPrice.toStringAsFixed(2)}\nTotal: \$${productTotalPrice}',
                                                                    style: TextStyle(fontSize: 14),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        );
                                    }).toList(),
                                ),
                            ],
                        ),
                    ),
                );
            },
        );
    }
}
