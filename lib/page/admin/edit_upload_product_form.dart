import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/edit';

  const EditOrUploadProductScreen({Key? key}) : super(key: key);

  @override
  State<EditOrUploadProductScreen> createState() => _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  String? _categoryValue;
  String? _groupValue;
  String? _sizeValue;
  String? _colorValue;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _batteryCapacityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();

  bool _isLoading = false;
  String? productImageUrl;

  // Tạo một tham chiếu đến cơ sở dữ liệu Firebase Realtime
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate() || _pickedImage == null) {
      Fluttertoast.showToast(
        msg: 'Please complete all fields and upload an image.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productId = const Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child('productsImages').child('$productId.jpg');
      await storageRef.putFile(File(_pickedImage!.path));
      productImageUrl = await storageRef.getDownloadURL();

      String productGroupPath = _groupValue == 'Phone' ? 'phone' : 'earphone';

      // Lưu sản phẩm vào Firebase Realtime Database
      _databaseRef.child('products/$productGroupPath/$productId').set({
        'productId': productId,
        'phoneName': _nameController.text,
        'price': int.parse(_priceController.text),
        'size': _sizeValue,
        'color': _colorValue,
        'rating': double.parse(_ratingController.text),
        'batteryCapacity': _batteryCapacityController.text,
        'category': _categoryValue,
        'description': _descriptionController.text,
        'imageURL': productImageUrl,
        'youtubeLink': _youtubeLinkController.text,
        'createdAt': ServerValue.timestamp,
      });

      Fluttertoast.showToast(
        msg: 'Product has been added successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      _clearForm();
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error uploading product: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _ratingController.clear();
    _batteryCapacityController.clear();
    _descriptionController.clear();
    _youtubeLinkController.clear();
    setState(() {
      _pickedImage = null;
      _categoryValue = null;
      _groupValue = null;
      _sizeValue = null;
      _colorValue = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _batteryCapacityController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit or Upload Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Đảm bảo cú pháp đúng
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ô chọn ảnh
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
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Ô chọn nhóm sản phẩm (Phone hoặc Earphone)
              DropdownButtonFormField<String>(
                value: _groupValue,
                items: ['Phone', 'Earphone'].map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _groupValue = value;
                  });
                },
                validator: (value) => value == null ? 'Please choose a group' : null,
              ),
              const SizedBox(height: 16),

              // Ô chọn loại sản phẩm dựa trên nhóm được chọn
              DropdownButtonFormField<String>(
                value: _categoryValue,
                items: (_groupValue == 'Phone')
                    ? ['Apple', 'Oppo', 'Samsung', 'Nokia', 'Xiaomi'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList()
                    : ['Apple', 'JBL', 'Sony', 'Sennheiser'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _categoryValue = value;
                  });
                },
                validator: (value) => value == null ? 'Please choose a category' : null,
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
                      items: (_groupValue == 'Phone')
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
                          _sizeValue = value;
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
                      items: ['White', 'Blue', 'Red', 'Purple', 'Brown', 'Pink', 'Black'].map((String color) {
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
                          _colorValue = value;
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
                  // Kiểm tra tính hợp lệ của liên kết
                  final isValidYouTubeLink = YoutubePlayer.convertUrlToId(value) != null;
                  if (!isValidYouTubeLink) {
                    return 'Please enter a valid YouTube video link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Hiển thị video YouTube (nếu liên kết hợp lệ)
              if (YoutubePlayer.convertUrlToId(_youtubeLinkController.text) != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: YoutubePlayer.convertUrlToId(_youtubeLinkController.text)!,
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                      ),
                    ),
                    aspectRatio: 16 / 9,
                  ),
                ),
              const SizedBox(height: 16),

              // Nút lưu sản phẩm
              Center(
                child: ElevatedButton(
                  onPressed: _uploadProduct,
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
