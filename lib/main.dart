import 'package:flutter/material.dart';
import 'package:myapp/login_page.dart';
import 'package:myapp/home_page.dart'; // Import HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melintu Desain',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(
              onLoginSuccess: (context) {
                Navigator.pushReplacementNamed(context, '/home');
              },
              onLoginProcess: (bool isLoading) {
                // Handle loading state here
              },
            ),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
