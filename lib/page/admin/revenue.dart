import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RevenuePage extends StatefulWidget {
        static const routeName = '/revenue';

    @override
    _RevenuePageState createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.reference();

    // Biến để lưu giữ năm đã chọn và tổng doanh thu
    int selectedYear = DateTime.now().year;
    double totalRevenue = 0;

    // Hàm để lấy danh sách năm có thể chọn (từ hiện tại trở lại)
    List<int> getAvailableYears() {
        final currentYear = DateTime.now().year;
        List<int> years = [];
        for (int year = currentYear; year >= 2000; year--) {
            years.add(year);
        }
        return years;
    }

    // Hàm để tính tổng doanh thu của năm đã chọn
    Future<void> calculateRevenue() async {
    double total = 0;

    // Truy vấn cơ sở dữ liệu để lấy danh sách đơn hàng chứa trạng thái 'approved' trong năm đã chọn
    final orderQuery = databaseRef.child('orders')
        .orderByChild('orderDate')
        .startAt('$selectedYear-01-01')
        .endAt('$selectedYear-12-31')
        .once();

    final event = await orderQuery;
    final orders = event.snapshot.value;

    // Kiểm tra nếu orders không rỗng
    if (orders != null && orders is Map) {
        // Lặp qua các user trong orders
        orders.forEach((userId, userOrders) {
            // Kiểm tra nếu userOrders là Map
            if (userOrders is Map) {
                // Lặp qua các đơn hàng trong userOrders
                userOrders.forEach((orderId, orderData) {
                    // Kiểm tra nếu orderData là Map
                    if (orderData is Map) {
                        // Kiểm tra trạng thái của đơn hàng
                        final status = orderData['status'];
                        final totalOrderCost = orderData['totalOrderCost'];

                        // Nếu trạng thái là 'approved', cộng totalOrderCost vào tổng
                        if (status == 'approved' && totalOrderCost != null) {
                            total += totalOrderCost;
                        }
                    }
                });
            }
        });
    }

    // Cập nhật totalRevenue trong state
    setState(() {
        totalRevenue = total;
    });
}

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Doanh thu'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        // Dropdown để chọn năm
                        DropdownButton<int>(
                            value: selectedYear,
                            items: getAvailableYears().map((year) {
                                return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                );
                            }).toList(),
                            onChanged: (newYear) {
                                setState(() {
                                    selectedYear = newYear!;
                                });
                            },
                        ),
                        const SizedBox(height: 20),
                        // Nút để tính tổng doanh thu
                        ElevatedButton(
                            onPressed: calculateRevenue,
                            child: Text('Tính tổng doanh thu'),
                        ),
                        const SizedBox(height: 20),
                        // Hiển thị tổng doanh thu
                        Text(
                            'Tổng doanh thu của năm $selectedYear: \$${totalRevenue.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                    ],
                ),
            ),
        );
    }
}
