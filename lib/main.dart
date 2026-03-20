import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:walletik/screens/home_screen.dart';
import 'package:walletik/screens/cards_screen.dart';
import 'package:walletik/screens/shopping_list_screen.dart';
import 'package:walletik/screens/settings_screen.dart';
import 'package:walletik/providers/theme_provider.dart';
import 'package:walletik/providers/card_provider.dart';
import 'package:walletik/providers/shopping_provider.dart';
import 'package:walletik/repositories/card_repository_impl.dart';
import 'package:walletik/repositories/shopping_repository_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => CardProvider(CardRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (context) => ShoppingProvider(ShoppingRepositoryImpl()),
        ),
      ],
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isModalOpen = false;
  bool _isNavigating = false;
  int? _targetIndex;

  late AnimationController _navBarAnimationController;
  late Animation<double> _navBarAnimation;

  @override
  void initState() {
    super.initState();
    _navBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _navBarAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _navBarAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _navBarAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    HomeScreen(
      onNavigateToCards: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      onModalStateChanged: (isOpen) {
        setState(() => _isModalOpen = isOpen);
        if (isOpen) {
          _navBarAnimationController.forward();
        } else {
          _navBarAnimationController.reverse();
        }
      },
    ),
    CardsScreen(
      onModalStateChanged: (isOpen) {
        setState(() => _isModalOpen = isOpen);
        if (isOpen) {
          _navBarAnimationController.forward();
        } else {
          _navBarAnimationController.reverse();
        }
      },
    ),
    const ShoppingListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          top: true,
          bottom: false,
          child: PageView(
            controller: _pageController,
            physics: _isModalOpen ? const NeverScrollableScrollPhysics() : null,
            onPageChanged: (index) {
              if (_isNavigating && _targetIndex != null && index != _targetIndex) {
                return;
              }

              setState(() {
                _currentIndex = index;
                if (_isNavigating && index == _targetIndex) {
                  _isNavigating = false;
                  _targetIndex = null;
                }
              });
            },
            children: _screens,
          ),
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _navBarAnimation,
          builder: (context, child) {
            if (_navBarAnimation.value < 0.1) {
              return const SizedBox.shrink();
            }
            return ClipRect(
              child: Transform.translate(
                offset: Offset(0, 80 * (1 - _navBarAnimation.value)),
                child: Opacity(
                  opacity: _navBarAnimation.value,
                  child: BottomNavigationBar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    currentIndex: _currentIndex,
                    selectedIconTheme: const IconThemeData(size: 28),
                    unselectedIconTheme: const IconThemeData(size: 24),
                    onTap: _isModalOpen ? null : (index) {
                      final isNonAdjacent = (index - _currentIndex).abs() > 1;

                      if (isNonAdjacent) {
                        setState(() {
                          _currentIndex = index;
                          _isNavigating = true;
                          _targetIndex = index;
                        });
                      } else {
                        setState(() => _currentIndex = index);
                      }

                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'My Cards'),
                      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
