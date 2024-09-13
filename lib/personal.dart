import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// bool _isDarkMode = false;
// Color get colorPrimary => _isDarkMode ? Color.fromARGB(255, 61, 61, 61) : Color.fromARGB(255, 249, 247, 247);
// Color get colorSecondary  => _isDarkMode ? Color.fromARGB(255, 48, 48, 48) : Color.fromARGB(255, 219, 226, 239);
// Color get colorTertiary  => _isDarkMode ? Color.fromARGB(255, 249, 247, 247) : Color.fromARGB(255, 63, 114, 175);
// Color get colorQuaternary  => _isDarkMode ? Color.fromARGB(255, 249, 247, 247) : Color.fromARGB(255, 17, 45, 78);

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // 通知所有的監聽器主題變更
  }

  Color get primaryColor => _isDarkMode ? Color.fromARGB(255, 61, 61, 61) : Color.fromARGB(255, 249, 247, 247);
  Color get secondaryColor => _isDarkMode ? Color.fromARGB(255, 48, 48, 48) : Color.fromARGB(255, 219, 226, 239);
  Color get tertiaryColor => _isDarkMode ? Color.fromARGB(255, 249, 247, 247) : Color.fromARGB(255, 63, 114, 175);
  Color get quaternaryColor => _isDarkMode ? Color.fromARGB(255, 249, 247, 247) : Color.fromARGB(255, 17, 45, 78);
}


class PersonalInfoPage extends StatefulWidget {
  @override
  final int userId;
  const PersonalInfoPage({Key? key, required this.userId}) : super(key: key);

  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userId.toString();
    _emailController.text = 'test@gmail.com';
  }

  void _save() {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String oldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (name.isNotEmpty && email.isNotEmpty && oldPassword.isNotEmpty && newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
      if (oldPassword != '12345678') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('舊密碼錯誤')),
        );
      } else if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密碼不一致')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功!')),
        );
        _oldPasswordController.text = '';
        _newPasswordController.text = '';
        _confirmPasswordController.text = '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入所有欄位')),
      );
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('登出成功!')),
    );
  }

  void _toggleDarkMode() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.primaryColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '個人資訊',
                    style: TextStyle(
                      fontSize: 32,
                      color: themeProvider.tertiaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        labelText: '舊密碼',
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
                            _isOldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: themeProvider.quaternaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isOldPasswordVisible = !_isOldPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: themeProvider.tertiaryColor),
                      obscureText: !_isOldPasswordVisible,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: '新密碼',
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
                            _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: themeProvider.quaternaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: themeProvider.tertiaryColor),
                      obscureText: !_isNewPasswordVisible,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: '確認新密碼',
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
                    onPressed: _save,
                    style: TextButton.styleFrom(
                      foregroundColor: themeProvider.primaryColor,
                      backgroundColor: themeProvider.tertiaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 178.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Custom border radius
                      ),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: _logout,
                    style: TextButton.styleFrom(
                      foregroundColor: themeProvider.primaryColor,
                      backgroundColor: themeProvider.tertiaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 178.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Custom border radius
                      ),
                    ),
                    child: const Text(
                      '登出',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              child: IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.brightness_3 : Icons.brightness_6, size: 30.0, color: Colors.grey),
                onPressed: _toggleDarkMode,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8.0), // Adjust the padding value as needed
            ),
          ),
        ],
      ),
    );
  }
}