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
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white), // Set your desired text color here
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
    final String userId = ModalRoute.of(context)!.settings.arguments as String;

    final List<Widget> pages = [
      const CourseManagementPage(),
      PromptManagementPage(),
      PersonalInfoPage(userId: userId), // Pass user_id to PersonalInfoPage
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.class_rounded),
            icon: Icon(Icons.class_outlined),
            label: '課程管理',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.design_services_rounded),
            icon: Icon(Icons.design_services_outlined),
            label: 'Prompt 管理',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle_rounded),
            icon: Icon(Icons.account_circle_outlined),
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