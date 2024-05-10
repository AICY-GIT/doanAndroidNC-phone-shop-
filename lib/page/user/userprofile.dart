import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileWidget extends StatefulWidget {
  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Nam';

  XFile? _selectedImage; // To store the selected image
  String _profileImageUrl = ''; // To store the profile image URL

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent snapshot = await _userRef.child(user.uid).once();
      Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        _fullNameController.text = userData['fullName'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _dobController.text = userData['dateofbirth'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _selectedGender = userData['gender'] ?? 'Nam';
        _profileImageUrl = userData['imagesusser'] ?? ''; // Load the profile image URL
      });
    }
  }

  void _chooseImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  Future<String> _uploadImage(XFile image) async {
    User? user = _auth.currentUser;
    if (user != null) {
      Reference storageRef = _storage.ref().child('profile_pictures').child('${user.uid}.jpg');
      UploadTask uploadTask = storageRef.putFile(File(image.path));
      await uploadTask;
      return await storageRef.getDownloadURL(); // Return the URL of the uploaded image
    }
    return '';
  }

  void _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String profileImageUrl = _profileImageUrl;

      // Upload the image if one is selected
      if (_selectedImage != null) {
        profileImageUrl = await _uploadImage(_selectedImage!);
      }

      // Update user data in the database
      await _userRef.child(user.uid).update({
        'fullName': _fullNameController.text,
        'address': _addressController.text,
        'dateofbirth': _dobController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'imagesusser': profileImageUrl, // Save the profile image URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thông tin đã được cập nhật thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ cá nhân'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Avatar section
            _buildAvatarSection(),
            Divider(height: 40),
            // Full name input
            _buildTextFormField(_fullNameController, 'Họ và tên'),
            Divider(height: 20),
            // Address input
            _buildTextFormField(_addressController, 'Địa chỉ'),
            Divider(height: 20),
            // Date of birth input
            _buildDatePickerField(),
            Divider(height: 20),
            // Gender input
            _buildGenderDropdown(),
            Divider(height: 20),
            // Phone input
            _buildPhoneField(),
            Divider(height: 40),
            // Save button
            ElevatedButton(
              onPressed: _saveUserProfile,
              child: Text('Lưu thông tin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
        backgroundImage: _selectedImage != null
    ? FileImage(File(_selectedImage!.path))
    : (_profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) : null as ImageProvider<Object>?),

          child: IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _chooseImage,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      controller: _dobController,
      decoration: InputDecoration(
        labelText: 'Ngày sinh',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue!;
        });
      },
      items: ['Nam', 'Nữ', 'Khác']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Giới tính',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Số điện thoại',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        // Check phone number format
        RegExp phoneRegExp = RegExp(r'^\d{10,11}$');
        if (!phoneRegExp.hasMatch(value)) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
    );
  }
}
