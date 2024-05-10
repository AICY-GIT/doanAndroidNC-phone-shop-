// ignore_for_file: prefer_const_constructors

import 'package:buoi4/page/admin/HomeAdmin.dart';
import 'package:buoi4/page/user/custom_scaffold.dart';
import 'package:buoi4/page/userwidget.dart';
import 'package:buoi4/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'registerwidget.dart';
import 'package:buoi4/theme/theme.dart';


class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);  

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
    final _formSignInKey = GlobalKey<FormState>();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');

    bool rememberPassword = true;

    @override
    Widget build(BuildContext context) {
        return CustomScaffold(
            child: Column(
                children: [
                    const Expanded(
                        flex: 1,
                        child: SizedBox(
                            height: 10,
                        ),
                    ),
                    Expanded(
                        flex: 7,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40.0),
                                    topRight: Radius.circular(40.0),
                                ),
                            ),
                            child: SingleChildScrollView(
                                child: Form(
                                    key: _formSignInKey,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Text(
                                                'Welcome back',
                                                style: TextStyle(
                                                    fontSize: 30.0,
                                                    fontWeight: FontWeight.w900,
                                                    color: lightColorScheme.primary,
                                                ),
                                            ),
                                            const SizedBox(
                                                height: 40.0,
                                            ),
                                            TextFormField(
                                                controller: _emailController,
                                                validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                        return 'Please enter Email';
                                                    }
                                                    return null;
                                                },
                                                decoration: InputDecoration(
                                                    label: const Text('Email'),
                                                    hintText: 'Enter Email',
                                                    hintStyle: const TextStyle(
                                                        color: Colors.black26,
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                            color: Colors.black12,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                            color: Colors.black12,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(
                                                height: 25.0,
                                            ),
                                            TextFormField(
                                                controller: _passwordController,
                                                obscureText: true,
                                                obscuringCharacter: '*',
                                                validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                        return 'Please enter Password';
                                                    }
                                                    return null;
                                                },
                                                decoration: InputDecoration(
                                                    label: const Text('Password'),
                                                    hintText: 'Enter Password',
                                                    hintStyle: const TextStyle(
                                                        color: Colors.black26,
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                            color: Colors.black12,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                            color: Colors.black12,
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(
                                                height: 25.0,
                                            ),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Row(
                                                        children: [
                                                            Checkbox(
                                                                value: rememberPassword,
                                                                onChanged: (bool? value) {
                                                                    setState(() {
                                                                        rememberPassword = value!;
                                                                    });
                                                                },
                                                                activeColor: lightColorScheme.primary,
                                                            ),
                                                            const Text(
                                                                'Remember me',
                                                                style: TextStyle(
                                                                    color: Colors.black45,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                            // Xử lý quên mật khẩu ở đây
                                                        },
                                                        child: Text(
                                                            'Forget password?',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: lightColorScheme.primary,
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(
                                                height: 25.0,
                                            ),
                                            SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                        if (_formSignInKey.currentState!.validate()) {
                                                            // Gọi hàm để xử lý đăng nhập
                                                            _signInWithEmailAndPassword(context, _emailController.text, _passwordController.text);
                                                        }
                                                    },
                                                    child: Text('Sign in'),
                                                ),
                                            ),
                                            // Các phần khác của UI vẫn giữ nguyên
                                            const SizedBox(
                                                height: 25.0,
                                            ),
                                            // Phần Social media sign in
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                    Image.asset(
                                                        'assets/images/facebook_icon.png',
                                                        width: 30,
                                                        height: 30,
                                                    ),
                                                    Image.asset(
                                                        'assets/images/twitter_icon.png',
                                                        width: 30,
                                                        height: 30,
                                                    ),
                                                    Image.asset(
                                                        'assets/images/google.png',
                                                        width: 30,
                                                        height: 30,
                                                    ),
                                                    Image.asset(
                                                        'assets/images/apple_icon.png',
                                                        width: 30,
                                                        height: 30,
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(
                                                height: 25.0,
                                            ),
                                            // Đã có tài khoản, điều hướng đến trang đăng ký
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    const Text(
                                                        'Don\'t have an account? ',
                                                        style: TextStyle(
                                                            color: Colors.black45,
                                                        ),
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (e) => const RegisterWidget(),
                                                                ),
                                                            );
                                                        },
                                                        child: Text(
                                                            'Sign up',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: lightColorScheme.primary,
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(
                                                height: 20.0,
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    // Hàm xử lý đăng nhập
    void _signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
        // Thực hiện xác thực người dùng bằng email và mật khẩu
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

        // Lấy UID của người dùng đã đăng nhập
        String uid = userCredential.user!.uid;
        print('UID đã đăng nhập: $uid');

        // Truy vấn thông tin người dùng từ cơ sở dữ liệu bằng UID
        DatabaseEvent event = await _userRef.child(uid).once();
        DataSnapshot snapshot = event.snapshot;

        // Kiểm tra và ép kiểu dữ liệu từ cơ sở dữ liệu
        if (snapshot.value is Map) {
            Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);

            // Kiểm tra vai trò của người dùng
            String role = userData['role'] ?? 'user';

            // Điều hướng dựa trên vai trò của người dùng
            if (role == 'admin') {
                // Chuyển hướng đến trang DashboardScreen nếu vai trò là admin
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeAdmin()),
                );
            } else {
                // Chuyển hướng đến trang RootPage nếu vai trò là user
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RootPage()),
                );
            }
        } else {
            // Nếu dữ liệu không hợp lệ, hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dữ liệu không chính xác')),
            );
        }
    } catch (error) {
        // Xử lý lỗi đăng nhập
        print('Đăng nhập không thành công: $error');
        String errorMessage = 'Đăng nhập không thành công';
        if (error is FirebaseAuthException) {
            errorMessage = error.message!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMessage),
            ),
        );
    }
}
}
