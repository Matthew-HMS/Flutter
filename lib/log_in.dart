// import 'package:flutter/material.dart';
// import 'package:ncu_emi/package/appbar.dart';



// class LogInPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LogInPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   void _login() {
//     final String email = _emailController.text;
//     final String password = _passwordController.text;

//     // 在这里处理登录逻辑
//     if (email.isNotEmpty && password.isNotEmpty) {
//       // 示例：打印用户输入的信息
//       print('Email: $email');
//       print('Password: $password');
//       Navigator.pushReplacementNamed(context, '/navigation');
//     } else {
//       // 提示用户输入信息
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('请输入邮箱和密码')),
//       );
//     }
//   }
// 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appbar(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 labelText: '邮箱',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                 labelText: '密码',
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text('登录'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }