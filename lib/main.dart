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
import 'package:walletik/widgets/card_detail_modal.dart';
import 'package:walletik/models/loyalty_card.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isModalOpen = false;
  bool _isNavigating = false;
  int? _targetIndex;
  late List<Widget> _screens;
  LoyaltyCard? _selectedCard;

  void _showCardDetail(LoyaltyCard card) {
    setState(() => _selectedCard = card);
  }

  void _closeModal() {
    setState(() => _selectedCard = null);
  }

  void _navigateToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onModalStateChanged(bool isOpen) {
    setState(() => _isModalOpen = isOpen);
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onNavigateToCards: _navigateToPage,
        onCardTap: _showCardDetail,
      ),
      CardsScreen(
        onCardTap: _showCardDetail,
      ),
      const ShoppingListScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        bottom: false,
        child: PageView(
          controller: _pageController,
          allowImplicitScrolling: true,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
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
        Positioned.fill(
          child: CardDetailModal(
            card: _selectedCard,
            onClose: _closeModal,
            onRefreshCards: () => context.read<CardProvider>().loadCards(),
            onModalStateChanged: _onModalStateChanged,
          ),
        ),
      ],
    );
  }
}
