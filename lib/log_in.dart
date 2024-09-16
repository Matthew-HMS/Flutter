import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_user.dart';
import 'personal.dart';
import 'dart:convert';

class LogInPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    try {
      if (email.isNotEmpty && password.isNotEmpty) {      
        print('Email: $email');
        print('Password: $password');
        final response = await ApiService.user_login(email,password);

        if (response.statusCode == 200) {                  
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final int userId = responseData['user_id'];
          // final String accessToken = responseData['access'];
          Navigator.pushReplacementNamed(
            context,
            '/navigation',
            arguments: userId, // Pass user_id as argument
          );
        }
        
      } else {
        // 提示用户输入信息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請輸入所有欄位')),
        );
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error : worng account or password ')),
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
                'EMI課程助教',
                style: TextStyle(
                  fontSize: 40,
                  color: themeProvider.tertiaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
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
              const SizedBox(height: 20.0),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    labelStyle: TextStyle(color: themeProvider.tertiaryColor),
                    border: OutlineInputBorder(),
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
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: _login, //登入後端
                style: TextButton.styleFrom(
                  foregroundColor: themeProvider.primaryColor, 
                  backgroundColor: themeProvider.tertiaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 178.0, vertical: 16.0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Custom border radius
                  ),
                ),
                child: const Text(
                  '登入',
                  style: TextStyle(fontSize: 20.0, color: Color.fromARGB(255, 249, 247, 247)), // Increase the font size
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '沒有帳號嗎?',
                    style: TextStyle(color: themeProvider.quaternaryColor),
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