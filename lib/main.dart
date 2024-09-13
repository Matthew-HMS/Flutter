import 'package:flutter/material.dart';
import 'prompt.dart';
import 'personal.dart';
import 'course.dart';
import 'log_in.dart';
import 'register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LogInPage(),
        '/navigation': (context) => const Navigation(),
        '/register': (context) => RegisterPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        navigationBarTheme: NavigationBarThemeData(          
          // indicatorColor: Colors.transparent,
          indicatorColor: Color.fromARGB(255, 249, 247, 247),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16, // 設定字體大小
              fontWeight: FontWeight.bold, // 設定字體粗細
              color: Color.fromARGB(255, 17, 45, 78)
              ), // Set your desired text color here
          ),
        ),
      ),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow; 

  @override
  Widget build(BuildContext context) {
    final int userId = ModalRoute.of(context)!.settings.arguments as int;
    final List<Widget> pages = [
      const CourseManagementPage(),
      PromptManagementPage(),
      PersonalInfoPage(userId: userId), // Pass user_id to PersonalInfoPage
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 219, 226, 239),
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.class_rounded,
              color: Color.fromARGB(255, 17, 45, 78), // 選中時的圖標顏色
            ),
            icon: Icon(
              Icons.class_outlined,
              color: Color.fromARGB(255, 17, 45, 78), // 未選中時的圖標顏色
            ),
            label: '課程管理',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.design_services_rounded,
              color: Color.fromARGB(255, 17, 45, 78), // 選中時的圖標顏色
            ),
            icon: Icon(
              Icons.design_services_outlined,
              color: Color.fromARGB(255, 17, 45, 78), // 未選中時的圖標顏色
            ),
            label: 'Prompt 管理',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.account_circle_rounded,
              color: Color.fromARGB(255, 17, 45, 78), // 選中時的圖標顏色
            ),
            icon: Icon(
              Icons.account_circle_outlined,
              color: Color.fromARGB(255, 17, 45, 78), // 未選中時的圖標顏色
            ),
            label: '個人資訊',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
    );
  }
}