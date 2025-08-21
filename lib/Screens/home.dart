import 'package:flutter/material.dart';
import '../colors.dart';
import './pages/homePage.dart';
import './pages/marketPlace.dart';
import './pages/shopLocator.dart';
import './pages/profilePage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ShopLocatorPage(),
    const MarketplacePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.lightGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: AppColors.iconGrey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store, color: AppColors.iconGrey),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: AppColors.iconGrey),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: AppColors.iconGrey),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
