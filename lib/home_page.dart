import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'user_list.dart';
import 'order_list_page.dart';
import 'profile_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int? _userId;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRole();
  }

  Future<void> _loadUserIdAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      try {
        final user = await ApiService().getUserById(userId);
        setState(() {
          _userId = userId;
          _userRole = user['role'];
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading user: $e');
        setState(() {
          _userId = null;
          _userRole = null;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _userId = null;
        _userRole = null;
        _isLoading = false;
      });
    }
  }

  void _handleLoginSuccess(BuildContext context) {
    _loadUserIdAndRole();
  }

  void _handleLoginProcess(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userId == null) {
      return Scaffold(
        body: LoginPage(
          onLoginSuccess: _handleLoginSuccess,
          onLoginProcess: _handleLoginProcess,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Melintu Design'),
        centerTitle: true,
        backgroundColor : const Color.fromARGB(255, 154, 60, 149),
        titleTextStyle: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),     
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _userRole == 'Admin'
            ? const <BottomNavigationBarItem>[
 BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.white),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.white),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ]
      : const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.white),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
  currentIndex: _selectedIndex,
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.white, // Color for unselected items
  backgroundColor: const Color.fromARGB(255, 154, 60, 149), // Background color
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
),
    );
  }

  List<Widget> get _widgetOptions => <Widget>[
        const OrderListPage(),
        if (_userRole == 'Admin') const UserList(),
        if (_userId != null) ProfilePage(userId: _userId!),
      ];
}
