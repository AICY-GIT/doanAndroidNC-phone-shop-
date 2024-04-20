import 'package:buoi4/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
    static const routeName = '/checkout';

    @override
    _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _addressController = TextEditingController();

    String? _fullName;
    List<Map<String, dynamic>> waitProducts = [];
    num _totalProductCost = 0;
    num _shippingCost = 0;
    num _totalOrderCost = 0;
    String _selectedDeliveryMethod = 'Thanh toán khi nhận hàng';

    @override
    void initState() {
        super.initState();
        _getUserFullName();
    }

    Future<void> _getUserFullName() async {
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid != null) {
            final userRef = FirebaseDatabase.instance.reference().child('users').child(uid);
            final userSnapshot = await userRef.once();

            if (userSnapshot.snapshot.value != null) {
                final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;
                final castedData = userData.cast<String, dynamic>();
                final fullName = castedData['fullName'] as String?;
                setState(() {
                    _fullName = fullName ?? '';
                });
            }
        }
    }

    bool _isFormValid() {
        return _phoneController.text.isNotEmpty && _addressController.text.isNotEmpty;
    }
void _handleCheckout() async {
    final phone = _phoneController.text;
    final address = _addressController.text;

    if (!_isFormValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter your phone number and address.')),
        );
        return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to proceed with checkout.')),
        );
        return;
    }

    // Đặt dữ liệu đơn hàng vào Firebase
final orderRef = FirebaseDatabase.instance.ref().child('orders').child(uid).push();
    final orderData = {
        'user_id': uid,
        'phone': phone,
        'address': address,
        'totalProductCost': _totalProductCost,
        'shippingCost': _shippingCost,
        'totalOrderCost': _totalOrderCost,
        'deliveryMethod': _selectedDeliveryMethod,
        'waitProducts': waitProducts,
        'orderDate': DateTime.now().toIso8601String(),
    };
    await orderRef.set(orderData);

    // Cập nhật trạng thái sản phẩm trong giỏ hàng và xóa khỏi carts
    final cartRef = FirebaseDatabase.instance.ref().child('carts').child(uid);
    List<Map<String, dynamic>> tempProducts = List.from(waitProducts);
    
    for (final product in tempProducts) {
        final productKey = product['key'];
        if (productKey != null) {
            // Cập nhật trạng thái của sản phẩm
            await cartRef.child(productKey).update({
                'state': 'complete',
            });
            // Xóa sản phẩm khỏi giỏ hàng
            await cartRef.child(productKey).remove();
        }
    }

    // Hiển thị thông báo thanh toán thành công
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
    );

    // Chuyển hướng đến trang HomeWidget sau khi thanh toán thành công
              Navigator.pushNamed(context, RootPage.routeName);
}

    @override
    Widget build(BuildContext context) {
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
            return Center(child: Text('Please log in to proceed with checkout.'));
        }

        final cartRef = FirebaseDatabase.instance.ref().child('carts').child(uid);

        return StreamBuilder<DatabaseEvent>(
            stream: cartRef.onValue,
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return Center(child: Text('No items in your cart.'));
                }

                final cartData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                waitProducts.clear();
                num totalProductCost = 0;

                if (cartData != null) {
                    cartData.forEach((key, value) {
                        final productMap = value as Map<dynamic, dynamic>;
                        final state = productMap['state'] as String?;

                        if (state == 'wait') {
                            final productKey = key;
                            final existingProduct = waitProducts.any((product) => product['key'] == productKey);

                            if (!existingProduct) {
                                final product = productMap.map((k, v) => MapEntry<String, dynamic>(k.toString(), v));
                                product['key'] = productKey;
                                waitProducts.add(product);

                                final price = product['price'] as num?;
                                final quantity = product['quantity'] as int?;

                                if (price != null && quantity != null) {
                                    final productTotal = price * quantity;
                                    totalProductCost += productTotal;
                                }
                            }
                        }
                    });
                }

                _shippingCost = totalProductCost / 10;
                _totalOrderCost = totalProductCost + _shippingCost;

                if (waitProducts.isEmpty) {
                    return Center(child: Text('No items in your cart with state "wait".'));
                }

                // Wrap the main content in a SingleChildScrollView to handle overflow
                return Scaffold(
                    appBar: AppBar(title: Text('Checkout')),
                    body: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                            'Full Name: ${_fullName ?? "Unknown"}',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: TextField(
                                            controller: _phoneController,
                                            decoration: InputDecoration(
                                                labelText: 'Phone Number',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                ),
                                            ),
                                        ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: TextField(
                                            controller: _addressController,
                                            decoration: InputDecoration(
                                                labelText: 'Address',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                ),
                                            ),
                                        ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: DropdownButton<String>(
                                                value: _selectedDeliveryMethod,
                                                onChanged: (String? newValue) {
                                                    setState(() {
                                                        _selectedDeliveryMethod = newValue!;
                                                    });
                                                },
                                                items: <String>[
                                                    'Thanh toán khi nhận hàng',
                                                    'Banking',
                                                    'Ví điện tử',
                                                ].map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            child: Text(value),
                                                        ),
                                                    );
                                                }).toList(),
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                                isExpanded: true,
                                            ),
                                        ),
                                    ),
                                    SizedBox(height: 10),
                                    // Product List View
                                    ListView.builder(
                                        shrinkWrap: true, // This allows ListView to adjust its height
                                        physics: NeverScrollableScrollPhysics(), // Prevent scrolling within ListView
                                        itemCount: waitProducts.length,
                                        itemBuilder: (context, index) {
                                            final product = waitProducts[index];
                                            final name = product['name'] as String?;
                                            final price = product['price'] as num?;
                                            final quantity = product['quantity'] as int? ?? 1;
                                            final imageUrl = product['imageURL'] as String?;

                                            return Card(
                                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                                ),
                                            );
                                        },
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Card(
                                            color: Colors.grey[200],
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: Column(
                                                    children: [
                                                        Text(
                                                            'Total Product Cost: \$${totalProductCost.toStringAsFixed(2)}',
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                        ),
                                                        Text(
                                                            'Shipping Cost: \$${_shippingCost.toStringAsFixed(2)}',
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                        ),
                                                        Text(
                                                            'Total Order Cost: \$${_totalOrderCost.toStringAsFixed(2)}',
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ),
                                    ElevatedButton(
                                        onPressed: _isFormValid() ? _handleCheckout : null,
                                        child: Text('Complete Checkout'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: _isFormValid() ? Colors.blue : Colors.grey,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                );
            },
        );
    }

    @override
    void dispose() {
        _phoneController.dispose();
        _addressController.dispose();
        super.dispose();
    }
}
