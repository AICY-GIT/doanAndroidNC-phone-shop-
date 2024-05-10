import 'package:buoi4/page/admin/order_processing.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrdersAdminPage extends StatefulWidget {
    static const routeName = '/ordersAdmin';

    const OrdersAdminPage({Key? key}) : super(key: key);

    @override
    _OrdersAdminPageState createState() => _OrdersAdminPageState();
}

class _OrdersAdminPageState extends State<OrdersAdminPage> {
    List<Map<String, dynamic>> userDataList = [];
    Map<String, int> userNotYetApprovedOrderCountMap = {};
    Map<String, int> userApprovedOrderCountMap = {};
    Map<String, int> userTotalOrderCountMap = {};

    @override
    void initState() {
        super.initState();
        _fetchUserData();
    }

    Future<void> _fetchUserData() async {
        final ordersRef = FirebaseDatabase.instance.reference().child('orders');
        final ordersSnapshot = await ordersRef.once();

        if (ordersSnapshot.snapshot.value != null) {
            final Set<String> userIds = Set<String>();
            final ordersData = ordersSnapshot.snapshot.value as Map<dynamic, dynamic>?;

            if (ordersData != null) {
                ordersData.forEach((userId, orders) {
                    if (orders != null) {
                        final ordersMap = Map<String, dynamic>.from(orders as Map<dynamic, dynamic>);
                        ordersMap.forEach((orderKey, orderValue) {
                            final order = Map<String, dynamic>.from(orderValue);
                            final status = order['status'] as String?;
                            final uid = order['user_id'] as String?;

                            if (uid != null) {
                                userTotalOrderCountMap[uid] = (userTotalOrderCountMap[uid] ?? 0) + 1;

                                if (status == 'not_yet_approved') {
                                    userNotYetApprovedOrderCountMap[uid] = (userNotYetApprovedOrderCountMap[uid] ?? 0) + 1;
                                    userIds.add(uid);
                                } else if (status == 'approved') {
                                    userApprovedOrderCountMap[uid] = (userApprovedOrderCountMap[uid] ?? 0) + 1;
                                }
                            }
                        });
                    }
                });
            }

            final usersRef = FirebaseDatabase.instance.reference().child('users');
            List<Map<String, dynamic>> tempUserDataList = [];

            for (final userId in userIds) {
                final userRef = usersRef.child(userId);
                final userSnapshot = await userRef.once();

                if (userSnapshot.snapshot.value != null) {
                    final userData = Map<String, dynamic>.from(userSnapshot.snapshot.value as Map<dynamic, dynamic>);
                    
                    tempUserDataList.add({
                        'user_id': userId,
                        'email': userData['email'],
                        'fullName': userData['fullName'],
                        'notYetApprovedOrderCount': userNotYetApprovedOrderCountMap[userId] ?? 0,
                        'approvedOrderCount': userApprovedOrderCountMap[userId] ?? 0,
                        'totalOrderCount': userTotalOrderCountMap[userId] ?? 0,
                    });
                }
            }

            setState(() {
                userDataList = tempUserDataList;
            });
        } else {
            print('No data in orders');
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Orders Admin')),
            body: ListView.builder(
                itemCount: userDataList.length,
                itemBuilder: (context, index) {
                    final userData = userDataList[index];
                    final userId = userData['user_id'] as String;

                    return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: ListTile(
                            onTap: () async {
                                final newOrders = await getNewOrders(userId);
                                final oldOrders = await getOldOrders(userId);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderProcessingPage(
                                            userId: userId,
                                            newOrders: newOrders,
                                            oldOrders: oldOrders,
                                        ),
                                    ),
                                );
                            },
                            title: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            'User ID: ${userData['user_id']}',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Email: ${userData['email']}',
                                            style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Full Name: ${userData['fullName']}',
                                            style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Đơn hàng mới: ${userData['notYetApprovedOrderCount']}',
                                            style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Đơn hàng cũ: ${userData['approvedOrderCount']}',
                                            style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            'Tổng số lượng đơn hàng: ${userData['totalOrderCount']}',
                                            style: TextStyle(fontSize: 14),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    );
                },
            ),
        );
    }

    Future<List<Map<String, dynamic>>> getNewOrders(String userId) async {
        final ordersRef = FirebaseDatabase.instance.reference().child('orders').child(userId);
        List<Map<String, dynamic>> newOrders = [];

        await ordersRef.once().then((DatabaseEvent event) {
            final ordersData = event.snapshot.value as Map<dynamic, dynamic>?;

            if (ordersData != null) {
                ordersData.forEach((orderKey, orderValue) {
                    final order = Map<String, dynamic>.from(orderValue);
                    final status = order['status'] as String?;

                    if (status == 'not_yet_approved') {
                        newOrders.add(order);
                    }
                });
            }
        });

        return newOrders;
    }

    Future<List<Map<String, dynamic>>> getOldOrders(String userId) async {
        final ordersRef = FirebaseDatabase.instance.reference().child('orders').child(userId);
        List<Map<String, dynamic>> oldOrders = [];

        await ordersRef.once().then((DatabaseEvent event) {
            final ordersData = event.snapshot.value as Map<dynamic, dynamic>?;

            if (ordersData != null) {
                ordersData.forEach((orderKey, orderValue) {
                    final order = Map<String, dynamic>.from(orderValue);
                    final status = order['status'] as String?;

                    if (status == 'approved') {
                        oldOrders.add(order);
                    }
                });
            }
        });

        return oldOrders;
    }
}
