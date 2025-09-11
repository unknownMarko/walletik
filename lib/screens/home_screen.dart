import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';
import '../widgets/loyalty_card.dart';
import '../services/card_storage.dart';
import '../utils/color_utils.dart';
import 'add_card_screen.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FadeScalePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  
  FadeScalePageRoute({required this.builder});
  
  @override
  Color? get barrierColor => Colors.black54;
  
  @override
  String? get barrierLabel => null;
  
  @override
  bool get barrierDismissible => false;
  
  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }
  
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
  
  @override
  bool get maintainState => true;
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToCards;
  final Function(bool)? onModalStateChanged;
  
  const HomeScreen({super.key, this.onNavigateToCards, this.onModalStateChanged});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> cards = [];
  List<Map<String, dynamic>> recentCards = [];
  Map<String, dynamic>? selectedCard;
  int? selectedCardIndex;
  
  late AnimationController _modalController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadCards();
    
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOutBack,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOutCubic,
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _modalController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCards() async {
    final loadedCards = await CardStorage.loadCards();
    setState(() {
      cards = loadedCards;
      recentCards = loadedCards.take(3).toList();
    });
  }
  
  void closeModal() {
    if (selectedCard != null) {
      _contentController.reverse();
      _modalController.reverse().then((_) {
        if (mounted) {
          setState(() {
            selectedCard = null;
            selectedCardIndex = null;
          });
          widget.onModalStateChanged?.call(false);
        }
      });
    }
  }
  
  void _showCardDetail(Map<String, dynamic> card, int index) {
    setState(() {
      selectedCard = card;
      selectedCardIndex = index;
    });
    widget.onModalStateChanged?.call(true);
    
    _modalController.reset();
    _contentController.reset();
    
    _modalController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _contentController.forward();
    });
  }
  
  String _generateBarcode(String data, String format) {
    Barcode barcode;
    switch (format) {
      case 'qrCode':
        barcode = Barcode.qrCode();
        break;
      case 'ean13':
        barcode = Barcode.ean13();
        break;
      case 'code39':
        barcode = Barcode.code39();
        break;
      case 'pdf417':
        barcode = Barcode.pdf417();
        break;
      case 'ean8':
        barcode = Barcode.ean8();
        break;
      case 'dataMatrix':
        barcode = Barcode.dataMatrix();
        break;
      default:
        barcode = Barcode.code128();
    }
    
    try {
      return barcode.toSvg(
        data, 
        width: format == 'qrCode' ? 200 : 280, 
        height: format == 'qrCode' ? 200 : 80
      );
    } catch (e) {
      final fallbackBarcode = Barcode.code128();
      return fallbackBarcode.toSvg(data, width: 280, height: 80);
    }
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.wallet,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Cards',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cards.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddCardScreen()),
                    );
                    
                    if (result != null && result is Map<String, dynamic>) {
                      final newCard = {
                        'shopName': result['name'],
                        'description': result['description'] ?? '',
                        'cardNumber': result['code'],
                        'color': '#0066CC',
                        'barcodeFormat': result['barcodeFormat'] ?? 'code128',
                      };
                      
                      await CardStorage.addCard(newCard);
                      await _loadCards();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onNavigateToCards?.call(1),
                  icon: const Icon(Icons.view_list),
                  label: const Text('View All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCards() {
    if (recentCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Cards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (cards.length > 3)
                TextButton(
                  onPressed: () => widget.onNavigateToCards?.call(1),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentCards.length,
              itemBuilder: (context, index) {
                final card = recentCards[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: index < recentCards.length - 1 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => _showCardDetail(card, index),
                    child: Hero(
                      tag: 'card_${card['shopName']}_${card['cardNumber']}',
                      child: Material(
                        color: Colors.transparent,
                        child: LoyaltyCard(
                          shopName: card['shopName'] ?? '',
                          description: card['description'] ?? '',
                          cardNumber: card['cardNumber'] ?? '',
                          cardColor: ColorUtils.hexToColor(card['color'] ?? '#0066CC'),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BackgroundLogo(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 28,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            'Walletik',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentCards(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedCard != null)
                GestureDetector(
                  onTap: closeModal,
                  child: AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Container(
                        color: Colors.black.withValues(alpha: _backgroundAnimation.value),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _modalController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Hero(
                                      tag: 'card_${selectedCard!['shopName']}_${selectedCard!['cardNumber']}',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
                                          height: 320,
                                          decoration: BoxDecoration(
                                            color: ColorUtils.hexToColor(selectedCard!['color']),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(24),
                                                child: AnimatedBuilder(
                                                  animation: _contentFadeAnimation,
                                                  builder: (context, child) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                    FadeTransition(
                                                      opacity: _contentFadeAnimation,
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: const Offset(0, 0.1),
                                                          end: Offset.zero,
                                                        ).animate(_contentController),
                                                        child: Text(
                                                          selectedCard!['shopName'],
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    FadeTransition(
                                                      opacity: Tween<double>(
                                                        begin: 0.0,
                                                        end: 1.0,
                                                      ).animate(CurvedAnimation(
                                                        parent: _contentController,
                                                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                                                      )),
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: const Offset(0, 0.1),
                                                          end: Offset.zero,
                                                        ).animate(CurvedAnimation(
                                                          parent: _contentController,
                                                          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                                                        )),
                                                        child: Text(
                                                          selectedCard!['description'],
                                                          style: const TextStyle(
                                                            color: Colors.white70,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    FadeTransition(
                                                      opacity: Tween<double>(
                                                        begin: 0.0,
                                                        end: 1.0,
                                                      ).animate(CurvedAnimation(
                                                        parent: _contentController,
                                                        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                                                      )),
                                                      child: Transform.scale(
                                                        scale: Tween<double>(
                                                          begin: 0.9,
                                                          end: 1.0,
                                                        ).animate(CurvedAnimation(
                                                          parent: _contentController,
                                                          curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                                                        )).value,
                                                        child: Center(
                                                          child: Container(
                                                            padding: const EdgeInsets.all(16),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: SvgPicture.string(
                                                              _generateBarcode(
                                                                selectedCard!['cardNumber'], 
                                                                selectedCard!['barcodeFormat'] ?? 'code128'
                                                              ),
                                                              width: selectedCard!['barcodeFormat'] == 'qrCode' ? 200 : 280,
                                                              height: selectedCard!['barcodeFormat'] == 'qrCode' ? 200 : 80,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    FadeTransition(
                                                      opacity: Tween<double>(
                                                        begin: 0.0,
                                                        end: 1.0,
                                                      ).animate(CurvedAnimation(
                                                        parent: _contentController,
                                                        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                                                      )),
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: const Offset(0, 0.2),
                                                          end: Offset.zero,
                                                        ).animate(CurvedAnimation(
                                                          parent: _contentController,
                                                          curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                                                        )),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                        IconButton(
                                                          onPressed: () async {
                                                            final result = await Navigator.push(
                                                              context,
                                                              FadeScalePageRoute(
                                                                builder: (context) => AddCardScreen(editCard: selectedCard),
                                                              ),
                                                            );
                                                            
                                                            if (result != null && result is Map<String, dynamic>) {
                                                              final updatedCard = {
                                                                'shopName': result['name'],
                                                                'description': result['description'] ?? '',
                                                                'cardNumber': result['code'],
                                                                'color': selectedCard!['color'],
                                                                'barcodeFormat': result['barcodeFormat'] ?? selectedCard!['barcodeFormat'] ?? 'code128',
                                                              };
                                                              
                                                              await CardStorage.updateCard(selectedCard!, updatedCard);
                                                              await _loadCards();
                                                              closeModal();
                                                            }
                                                          },
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Colors.white70,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withValues(alpha: 0.1),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: const Text('Delete Card'),
                                                                    content: Text('Are you sure you want to delete ${selectedCard!['shopName']}?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(context),
                                                                        child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () async {
                                                                          final navigator = Navigator.of(context);
                                                                          if (selectedCard != null) {
                                                                            await CardStorage.removeCard(selectedCard!);
                                                                            await _loadCards();
                                                                            if (mounted) {
                                                                              closeModal();
                                                                            }
                                                                          }
                                                                          navigator.pop();
                                                                        },
                                                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                            padding: EdgeInsets.zero,
                                                          ),
                                                        ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 16,
                                                right: 16,
                                                child: FadeTransition(
                                                  opacity: Tween<double>(
                                                    begin: 0.0,
                                                    end: 1.0,
                                                  ).animate(CurvedAnimation(
                                                    parent: _contentController,
                                                    curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                                                  )),
                                                  child: Transform.scale(
                                                    scale: Tween<double>(
                                                      begin: 0.8,
                                                      end: 1.0,
                                                    ).animate(CurvedAnimation(
                                                      parent: _contentController,
                                                      curve: const Interval(0.8, 1.0, curve: Curves.easeOutBack),
                                                    )).value,
                                                    child: IconButton(
                                                      onPressed: closeModal,
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}