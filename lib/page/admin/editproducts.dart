import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EditProductsScreen extends StatefulWidget {
    static const routeName = '/editproducts';

    final String productKey; // ID của sản phẩm cần chỉnh sửa
    final String group; // Nhóm sản phẩm (phone hoặc earphone)

    const EditProductsScreen({Key? key, required this.productKey, required this.group}) : super(key: key);

    @override
    _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
    final _formKey = GlobalKey<FormState>();
    late TextEditingController _nameController;
    late TextEditingController _priceController;
    late TextEditingController _ratingController;
    late TextEditingController _batteryCapacityController;
    late TextEditingController _descriptionController;
    late TextEditingController _youtubeLinkController; // Controller cho ô nhập liên kết video YouTube

    late YoutubePlayerController _youtubePlayerController;
    String? _groupValue;
    String? _categoryValue;
    String? _sizeValue;
    String? _colorValue;
    String? _imageURL;
    XFile? _pickedImage;

    @override
    void initState() {
        super.initState();

        // Khởi tạo các bộ điều khiển
        _nameController = TextEditingController();
        _priceController = TextEditingController();
        _ratingController = TextEditingController();
        _batteryCapacityController = TextEditingController();
        _descriptionController = TextEditingController();
        _youtubeLinkController = TextEditingController(); // Controller cho ô nhập liên kết video YouTube

        // Lấy thông tin sản phẩm từ cơ sở dữ liệu
        final databaseRef = FirebaseDatabase.instance.ref().child('products/${widget.group}/${widget.productKey}');
        databaseRef.once().then((DatabaseEvent event) {
            final productData = event.snapshot.value as Map<dynamic, dynamic>?;

            if (productData == null) {
                Fluttertoast.showToast(
                    msg: 'Product not found.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                );
                Navigator.pop(context); // Trở về trang trước
                return;
            }

            // Điền thông tin sản phẩm vào các bộ điều khiển
            _nameController.text = productData['phoneName'] ?? '';
            _priceController.text = productData['price']?.toString() ?? '';
            _ratingController.text = productData['rating']?.toString() ?? '';
            _batteryCapacityController.text = productData['batteryCapacity'] ?? '';
            _descriptionController.text = productData['description'] ?? '';
            _categoryValue = productData['category'] ?? '';
            _sizeValue = productData['size'] ?? '';
            _colorValue = productData['color'] ?? '';
            _imageURL = productData['imageURL'] ?? '';
            _youtubeLinkController.text = productData['youtubeLink'] ?? ''; // Đặt giá trị cho ô nhập liên kết video YouTube

            // Khởi tạo YoutubePlayerController
            final videoId = YoutubePlayer.convertUrlToId(_youtubeLinkController.text);
            _youtubePlayerController = YoutubePlayerController(
                initialVideoId: videoId ?? '',
                flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                ),
            );

            // Cập nhật giao diện
            setState(() {});
        });
    }

    @override
    void dispose() {
        // Giải phóng các bộ điều khiển
        _nameController.dispose();
        _priceController.dispose();
        _ratingController.dispose();
        _batteryCapacityController.dispose();
        _descriptionController.dispose();
        _youtubeLinkController.dispose();
        _youtubePlayerController.dispose(); // Giải phóng bộ nhớ của controller YoutubePlayer
        super.dispose();
    }

    // Phương thức chọn ảnh từ thư viện
    Future<void> _pickImage() async {
        final picker = ImagePicker();
        final pickedImage = await picker.pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
            setState(() {
                _pickedImage = pickedImage;
            });
        }
    }

    // Phương thức cập nhật sản phẩm
    Future<void> _updateProduct() async {
        if (_formKey.currentState!.validate()) {
            final productRef = FirebaseDatabase.instance.ref().child('products/${widget.group}/${widget.productKey}');

            try {
                // Nếu có ảnh mới được chọn, tải ảnh lên Firebase Storage
                String? imageUrl;
                if (_pickedImage != null) {
                    final storageRef = FirebaseStorage.instance.ref().child('productsImages/${widget.productKey}.jpg');
                    await storageRef.putFile(File(_pickedImage!.path));
                    imageUrl = await storageRef.getDownloadURL();
                }

                // Cập nhật thông tin sản phẩm trong cơ sở dữ liệu
                await productRef.update({
                    'phoneName': _nameController.text,
                    'price': double.tryParse(_priceController.text) ?? 0,
                    'size': _sizeValue,
                    'color': _colorValue,
                    'rating': double.tryParse(_ratingController.text) ?? 0,
                    'batteryCapacity': _batteryCapacityController.text,
                    'category': _categoryValue,
                    'description': _descriptionController.text,
                    'imageURL': imageUrl ?? _imageURL, // Sử dụng imageUrl nếu có, nếu không sử dụng _imageURL hiện tại
                    'youtubeLink': _youtubeLinkController.text,
                });

                Fluttertoast.showToast(
                    msg: 'Product updated successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                );

                // Quay lại trang list và làm mới dữ liệu
                Navigator.popAndPushNamed(context, '/listproducts');
            } catch (error) {
                Fluttertoast.showToast(
                    msg: 'Error updating product: $error',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Edit Product'),
            ),
            body: _nameController.text.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Trường chỉnh sửa ảnh
                                Row(
                                    children: [
                                        ElevatedButton(
                                            onPressed: _pickImage,
                                            child: Row(
                                                children: [
                                                    const Icon(Icons.image),
                                                    const SizedBox(width: 10),
                                                    const Text('Choose Image'),
                                                ],
                                            ),
                                        ),
                                        if (_pickedImage != null)
                                            Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: SizedBox(
                                                    width: 150,
                                                    height: 100,
                                                    child: Image.file(
                                                        File(_pickedImage!.path),
                                                        fit: BoxFit.cover,
                                                    ),
                                                ),
                                            )
                                        else if (_imageURL?.isNotEmpty ?? false)
                                            Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: SizedBox(
                                                    width: 150,
                                                    height: 100,
                                                    child: Image.network(
                                                        _imageURL ?? '',
                                                        fit: BoxFit.cover,
                                                    ),
                                                ),
                                            ),
                                    ],
                                ),
                                const SizedBox(height: 16),

                                // Ô nhập tên sản phẩm
                                TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                        labelText: 'Product Name',
                                        hintText: 'Enter product name',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                        ),
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return 'Please enter the product name';
                                        }
                                        return null;
                                    },
                                ),
                                const SizedBox(height: 16),

                                // Ô nhập giá sản phẩm và chọn kích thước
                                Row(
                                    children: [
                                        Expanded(
                                            child: TextFormField(
                                                controller: _priceController,
                                                decoration: InputDecoration(
                                                    labelText: 'Price (\$)',
                                                    hintText: 'Enter price',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    prefixText: '\$',
                                                ),
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                    final price = double.tryParse(value ?? '');
                                                    if (price == null) {
                                                        return 'Please enter a valid price';
                                                    }
                                                    return null;
                                                },
                                            ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: DropdownButtonFormField<String>(
                                                value: _sizeValue,
                                                items: (widget.group == 'phone')
                                                    ? ['256GB', '512GB', '1TB'].map((String size) {
                                                        return DropdownMenuItem<String>(
                                                            value: size,
                                                            child: Text(size),
                                                        );
                                                    }).toList()
                                                    : ['8h', '24h', '32h', '48h', '60h', '80h'].map((String size) {
                                                        return DropdownMenuItem<String>(
                                                            value: size,
                                                            child: Text(size),
                                                        );
                                                    }).toList(),
                                                decoration: InputDecoration(
                                                    labelText: 'Size',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                ),
                                                onChanged: (value) {
                                                    setState(() {
                                                        _sizeValue = value!;
                                                    });
                                                },
                                                validator: (value) => value == null ? 'Please choose a size' : null,
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 16),

                                // Ô chọn màu sắc và đánh giá sản phẩm
                                Row(
                                    children: [
                                        Expanded(
                                            child: DropdownButtonFormField<String>(
                                                value: _colorValue,
                                                items: ['White', 'Blue', 'Red', 'Purple', 'Orange', 'Pink', 'Black'].map((color) {
                                                    return DropdownMenuItem<String>(
                                                        value: color,
                                                        child: Text(color),
                                                    );
                                                }).toList(),
                                                decoration: InputDecoration(
                                                    labelText: 'Color',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                ),
                                                onChanged: (value) {
                                                    setState(() {
                                                        _colorValue = value!;
                                                    });
                                                },
                                                validator: (value) => value == null ? 'Please choose a color' : null,
                                            ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: TextFormField(
                                                controller: _ratingController,
                                                decoration: InputDecoration(
                                                    labelText: 'Rating',
                                                    hintText: 'Enter rating',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                ),
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                    final rating = double.tryParse(value ?? '');
                                                    if (rating == null) {
                                                        return 'Please enter a valid rating';
                                                    }
                                                    return null;
                                                },
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 16),

                                // Ô nhập dung lượng pin và mô tả sản phẩm
                                Row(
                                    children: [
                                        Expanded(
                                            child: TextFormField(
                                                controller: _batteryCapacityController,
                                                decoration: InputDecoration(
                                                    labelText: 'Battery Capacity',
                                                    hintText: 'Enter capacity',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                ),
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                    final capacity = double.tryParse(value ?? '');
                                                    if (capacity == null) {
                                                        return 'Please enter a valid battery capacity';
                                                    }
                                                    return null;
                                                },
                                            ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: TextFormField(
                                                controller: _descriptionController,
                                                decoration: InputDecoration(
                                                    labelText: 'Description',
                                                    hintText: 'Enter description',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                maxLines: null,
                                                validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                        return 'Please enter a description';
                                                    }
                                                    return null;
                                                },
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 16),

                                // Ô nhập liên kết video YouTube
                                TextFormField(
                                    controller: _youtubeLinkController,
                                    decoration: InputDecoration(
                                        labelText: 'YouTube Video Link',
                                        hintText: 'Enter YouTube video link',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                        ),
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return 'Please enter a YouTube video link';
                                        }
                                        final videoId = YoutubePlayer.convertUrlToId(value);
                                        if (videoId == null) {
                                            return 'Please enter a valid YouTube video link';
                                        }
                                        return null;
                                    },
                                    onChanged: (value) {
                                        setState(() {
                                            final videoId = YoutubePlayer.convertUrlToId(value);
                                            if (videoId != null) {
                                                _youtubePlayerController.load(videoId);
                                            }
                                        });
                                    },
                                ),
                                const SizedBox(height: 16),

                                // Hiển thị video YouTube (nếu liên kết hợp lệ)
                                YoutubePlayer(
                                    controller: _youtubePlayerController,
                                    aspectRatio: 16 / 9,
                                ),
                                const SizedBox(height: 16),

                                // Nút lưu sản phẩm
                                Center(
                                    child: ElevatedButton(
                                        onPressed: _updateProduct,
                                        child: const Text('Save Product'),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
        );
    }
}
