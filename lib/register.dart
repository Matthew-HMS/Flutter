import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_user.dart';
import 'personal.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;


  void _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        print('Email: $email');
        print('Password: $password');

        try {
          final response = await ApiService.user_register(email, password, name);

          if (response.statusCode == 201) {                  
            Navigator.pushReplacementNamed(context, '/');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('註冊成功! 請登入以使用系統')),
            );
          }
          else if (response.statusCode == 400) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('帳號重複，請重新輸入')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error : $e')),
          );
        }
          
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密碼不一致')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入所有欄位')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: themeProvider.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '會員註冊',
                style: TextStyle(
                  fontSize: 32,
                  color: themeProvider.tertiaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '姓名',
                    labelStyle: TextStyle(color: themeProvider.tertiaryColor),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                  ),
                  style: TextStyle(color: themeProvider.tertiaryColor),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                    labelText: '電子郵件',
                    labelStyle: TextStyle(color: themeProvider.tertiaryColor),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                  ),
                  style: TextStyle(color: themeProvider.tertiaryColor),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    labelStyle:  TextStyle(color: themeProvider.tertiaryColor),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: themeProvider.quaternaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(color: themeProvider.tertiaryColor),
                  obscureText: !_isPasswordVisible,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: '確認密碼',
                    labelStyle: TextStyle(color: themeProvider.tertiaryColor),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.quaternaryColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: themeProvider.quaternaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(color: themeProvider.tertiaryColor),
                  obscureText: !_isConfirmPasswordVisible,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _register,
                style: TextButton.styleFrom(
                  foregroundColor: themeProvider.primaryColor, 
                  backgroundColor: themeProvider.tertiaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 178.0, vertical: 16.0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Custom border radius
                  ),
                ),
                child: const Text(
                  '註冊',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '已經有帳號？',
                    style: TextStyle(color: themeProvider.quaternaryColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.lightBlue,
                    ),
                    child: const Text('登入'),
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