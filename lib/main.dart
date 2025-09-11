import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:walletik/screens/cards_screen.dart';
import 'package:walletik/screens/search_screen.dart';
import 'package:walletik/screens/settings_screen.dart';
import 'package:walletik/providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Walletik :)',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isModalOpen = false;
  VoidCallback? _closeCardsModal;

  List<Widget> get _screens => [
    CardsScreen(
      onModalStateChanged: (isOpen) => setState(() => _isModalOpen = isOpen),
      onCloseModalCallback: (callback) => _closeCardsModal = callback,
    ),
    const SearchScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: _isModalOpen ? const NeverScrollableScrollPhysics() : null,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: _isModalOpen ? 
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _closeCardsModal?.call();
              setState(() => _isModalOpen = false);
            },
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              currentIndex: _currentIndex,
              onTap: null,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'My Cards'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          ),
        ) :
        BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: const IconThemeData(size: 24),
          onTap: (index) {
            setState(() => _currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'My Cards'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
    );
  }
}
