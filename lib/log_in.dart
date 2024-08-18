import 'package:flutter/material.dart';

const backgroundColor = Color.fromARGB(255, 61, 61, 61);

class LogInPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    // 在这里处理登录逻辑
    if (email.isNotEmpty && password.isNotEmpty) {
      // 示例：打印用户输入的信息
      print('Email: $email');
      print('Password: $password');
      Navigator.pushReplacementNamed(context, '/navigation');
    } else {
      // 提示用户输入信息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入所有欄位')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'EMI課程助教',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '電子郵件',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: !_isPasswordVisible,
                ),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: _login, //登入後端
                style: TextButton.styleFrom(
                  foregroundColor: Colors.lightBlue, 
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Button size
                ),
                child: const Text(
                  '登入',
                  style: TextStyle(fontSize: 20.0), // Increase the font size
                ),
              ),
              const Text(
                '或',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.lightBlue, 
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Button size
                ),
                child: const Text(
                  'Google帳號登入',
                  style: TextStyle(fontSize: 20.0), // Increase the font size
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '沒有帳號嗎?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.lightBlue, 
                    ),
                    child: const Text('註冊'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}