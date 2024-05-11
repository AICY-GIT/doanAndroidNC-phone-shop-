import 'package:buoi4/page/product/checkout.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailPage extends StatelessWidget {
    final String group; // Nhóm sản phẩm (phone hoặc earphone)
    final String productId; // ID của sản phẩm

    const DetailPage({required this.group, required this.productId, Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        // Tạo tham chiếu đến sản phẩm trong cơ sở dữ liệu
        final DatabaseReference productRef = FirebaseDatabase.instance.ref().child('products').child(group).child(productId);

        // Sử dụng StreamBuilder để lắng nghe thay đổi dữ liệu sản phẩm
        return StreamBuilder<DatabaseEvent>(
            stream: productRef.onValue,
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Kiểm tra dữ liệu sản phẩm
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text('No product found.'));
                }

                // Lấy dữ liệu sản phẩm và ép kiểu an toàn
                final productData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                if (productData == null) {
                    return const Center(child: Text('No product found.'));
                }

                // Chuyển đổi kiểu dữ liệu từ Map<dynamic, dynamic> thành Map<String, dynamic>
                final productMap = productData.map((key, value) => MapEntry<String, dynamic>(key.toString(), value as dynamic));

                // Lấy thông tin sản phẩm từ productMap
                final name = productMap['phoneName'] as String? ?? 'No name';
                final price = productMap['price'] as num? ?? 0;
                final category = productMap['category'] as String? ?? 'No category';
                final imageUrl = productMap['imageURL'] as String? ?? '';
                final description = productMap['description'] as String? ?? 'No description';
                final rating = productMap['rating'] as num? ?? 0;
                final color = productMap['color'] as String? ?? 'No color';
                final size = productMap['size'] as String? ?? 'No size';
                final state = 'wait';
                
                // Xử lý thuộc tính batteryCapacity
                num? batteryCapacity;
                final batteryCapacityValue = productMap['batteryCapacity'];
                if (batteryCapacityValue is num) {
                    batteryCapacity = batteryCapacityValue;
                } else if (batteryCapacityValue is String) {
                    batteryCapacity = num.tryParse(batteryCapacityValue);
                } else {
                    batteryCapacity = null;
                }

                // Lấy liên kết YouTube từ productMap và chuyển đổi thành videoId
                final youtubeLink = productMap['youtubeLink'] as String? ?? '';
                final videoId = YoutubePlayer.convertUrlToId(youtubeLink);

                // Khởi tạo YoutubePlayerController
                final youtubePlayerController = YoutubePlayerController(
                    initialVideoId: videoId ?? '',
                    flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                    ),
                );

                // Hiển thị thông tin sản phẩm trong giao diện
                return Scaffold(
                    appBar: AppBar(
                        title: Text(name),
                    ),
                    body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const SizedBox(height: 10),
                            // Row chứa hình ảnh và thông tin size, color, batteryCapacity
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    // Hiển thị hình ảnh sản phẩm bên trái
                                    if (imageUrl.isNotEmpty)
                                        Padding(
                                            padding: const EdgeInsets.only(left: 30.0),
                                            child: Image.network(
                                                imageUrl,
                                                width: 100,
                                                height: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.error);
                                                },
                                            ),
                                        ),
                                    const SizedBox(width: 20),
                                    // Hiển thị size, color, và batteryCapacity bên phải bức ảnh
                                    Padding(
                                        padding: const EdgeInsets.only(left: 30.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'Storage Capacity',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: Color.fromARGB(255, 49, 47, 47),
                                                        fontSize: 18,
                                                    ),
                                                ),
                                                Text(
                                                    '${size}',
                                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                                        fontSize: 16.0,
                                                    ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                    'Color',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: Color.fromARGB(255, 49, 47, 47),
                                                        fontSize: 18,
                                                    ),
                                                ),
                                                Text(
                                                    '${color}',
                                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                                        fontSize: 16.0,
                                                    ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                    'Battery Capacity',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: Color.fromARGB(255, 49, 47, 47),
                                                        fontSize: 18,
                                                    ),
                                                ),
                                                Text(
                                                    '${batteryCapacity} mAh',
                                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                                        fontSize: 16.0,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                            const SizedBox(height: 20),
                            // Mục hiển thị video YouTube
                            if (videoId != null && videoId.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: YoutubePlayer(
                                        controller: youtubePlayerController,
                                        aspectRatio: 16 / 9,
                                    ),
                                ),
                            const SizedBox(height: 30),
                            // Expanded chứa các thông tin sản phẩm còn lại, kéo dài xuống dưới cùng của màn hình
                            Expanded(
                                child: Container(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 198, 218, 236),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(28),
                                            topRight: Radius.circular(28),
                                        ),
                                    ),
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const SizedBox(height: 20),
                                                // Tên sản phẩm
                                                Padding(
                                                    padding: const EdgeInsets.only(bottom: 10.0),
                                                    child: Text(
                                                        name,
                                                        style: Theme.of(context).textTheme.headline5?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 25,
                                                        ),
                                                    ),
                                                ),
                                                
                                                // Giá sản phẩm
                                                Padding(
                                                    padding: const EdgeInsets.only(bottom: 10.0),
                                                    child: Text(
                                                        '\$${price}',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 25,
                                                            color: Colors.black,
                                                        ),
                                                    ),
                                                ),
                                                // Mô tả sản phẩm
                                                Container(
                                                    height: 100,
                                                    child: SingleChildScrollView(
                                                        child: Padding(
                                                            padding: const EdgeInsets.only(bottom: 10.0),
                                                            child: Text(
                                                                description,
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                const SizedBox(height: 30), // Khoảng trống sau phần mô tả
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        // Biểu tượng thêm vào giỏ hàng
                                                        IconButton(
                                                            icon: const Icon(Icons.add_shopping_cart),
                                                            color: Colors.black,
                                                            iconSize: 30,
                                                            onPressed: () async {
                                                                // Lấy UID của người dùng đang đăng nhập
                                                                final uid = FirebaseAuth.instance.currentUser?.uid;

                                                                if (uid != null) {
                                                                    // Tạo tham chiếu đến giỏ hàng của người dùng
                                                                    final cartRef = FirebaseDatabase.instance.ref().child('carts').child(uid);

                                                                    // Kiểm tra xem sản phẩm đã tồn tại trong giỏ hàng hay chưa
                                                                    final event = await cartRef.child(productId).once();
                                                                    final cartSnapshot = event.snapshot;

                                                                    if (cartSnapshot.exists) {
                                                                        // Lấy giá trị từ DataSnapshot
                                                                        final value = cartSnapshot.value;

                                                                        // Kiểm tra nếu value không phải là null và chứa thuộc tính 'quantity'
                                                                        if (value != null && value is Map && value.containsKey('quantity')) {
                                                                            // Lấy số lượng hiện tại của sản phẩm
                                                                            final currentQuantity = value['quantity'] as int;

                                                                            // Tăng số lượng sản phẩm
                                                                            final newQuantity = currentQuantity + 1;
                                                                            await cartRef.child(productId).update({
                                                                                'quantity': newQuantity,
                                                                            });
                                                                        }
                                                                    } else {
                                                                        // Sản phẩm chưa tồn tại trong giỏ hàng, thêm sản phẩm mới
                                                                        await cartRef.child(productId).set({
                                                                            'name': name,
                                                                            'price': price,
                                                                            'category': category,
                                                                            'imageURL': imageUrl,
                                                                            'description': description,
                                                                            'rating': rating,
                                                                            'color': color,
                                                                            'size': size,
                                                                            'state': 'wait',
                                                                            'batteryCapacity': batteryCapacity,
                                                                            'group': group,
                                                                            'quantity': 1,
                                                                        });
                                                                    }
                                                                }

                                                                // Thông báo cho người dùng về việc sản phẩm đã được thêm vào giỏ hàng
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                        content: Text('$name đã được thêm vào giỏ hàng.'),
                                                                        duration: Duration(seconds: 2), // Thời gian hiển thị SnackBar (2 giây)
                                                                    ),
                                                                );
                                                            },
                                                        ),
                                                        const SizedBox(width: 20), // Khoảng trống giữa hai nút

                                                        // Nút "Buy Now"
                                                        ElevatedButton(
                                                            onPressed: () {
                                                                // Chuẩn bị dữ liệu sản phẩm
                                                                final productData = {
                                                                    'name': name,
                                                                    'price': price,
                                                                    'category': category,
                                                                    'imageURL': imageUrl,
                                                                    'description': description,
                                                                    'rating': rating,
                                                                    'color': color,
                                                                    'size': size,
                                                                    'batteryCapacity': batteryCapacity,
                                                                    'group': group,
                                                                    'quantity': 1, // Mặc định số lượng mua là 1
                                                                };

                                                                // Điều hướng người dùng đến trang CheckoutPage và truyền dữ liệu sản phẩm
                                                                Navigator.pushNamed(context, CheckoutPage.routeName, arguments: productData);
                                                            },
                                                            child: const Text('Buy Now'),
                                                            style: ElevatedButton.styleFrom(
                                                                minimumSize: const Size(270, 40), // Kích thước nút
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ),
                        ],
                    ),
                );
            },
        );
    }
}
