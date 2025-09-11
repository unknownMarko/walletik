import 'package:flutter/material.dart';
import 'add_card_screen.dart';
import '../widgets/loyalty_card.dart';
import '../widgets/background_logo.dart';
import '../services/card_storage.dart';
import '../utils/color_utils.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardsScreen extends StatefulWidget {
  final Function(bool)? onModalStateChanged;
  final Function(VoidCallback)? onCloseModalCallback;
  
  const CardsScreen({super.key, this.onModalStateChanged, this.onCloseModalCallback});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allCards = [];
  List<Map<String, dynamic>> filteredCards = [];
  Map<String, dynamic>? selectedCard;

  @override
  void initState() {
    super.initState();
    _loadCards();
    widget.onCloseModalCallback?.call(closeModal);
    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCards() async {
    final loadedCards = await CardStorage.loadCards();
    setState(() {
      allCards = loadedCards;
      filteredCards = loadedCards;
    });
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCards = allCards;
      } else {
        filteredCards = allCards.where((card) {
          final shopName = (card['shopName'] ?? '').toLowerCase();
          final description = (card['description'] ?? '').toLowerCase();
          final cardNumber = (card['cardNumber'] ?? '').toLowerCase();
          return shopName.contains(query) ||
              description.contains(query) ||
              cardNumber.contains(query);
        }).toList();
      }
    });
  }
  
  void closeModal() {
    if (selectedCard != null) {
      setState(() => selectedCard = null);
      widget.onModalStateChanged?.call(false);
    }
  }
  
  String _generateBarcode(String data) {
    final barcode = Barcode.code128();
    return barcode.toSvg(data, width: 280, height: 80);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
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
            };
            
            await CardStorage.addCard(newCard);
            await _loadCards();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: BackgroundLogo(
        child: SafeArea(
          child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search cards...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                Expanded(
                  child: filteredCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wallet_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'No cards yet'
                                    : 'No matching cards found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: filteredCards.length,
            itemBuilder: (context, index) {
              final card = filteredCards[index];
              return GestureDetector(
                onTap: () {
                  setState(() => selectedCard = card);
                  widget.onModalStateChanged?.call(true);
                },
                child: LoyaltyCard(
                  shopName: card['shopName'],
                  description: card['description'],
                  cardNumber: card['cardNumber'],
                  cardColor: ColorUtils.hexToColor(card['color']),
                ),
              );
            },
                  ),
                ),
              ],
            ),
          if (selectedCard != null)
            GestureDetector(
              onTap: () {
                setState(() => selectedCard = null);
                widget.onModalStateChanged?.call(false);
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedCard!['shopName'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedCard!['description'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SvgPicture.string(
                                  _generateBarcode(selectedCard!['cardNumber']),
                                  width: 280,
                                  height: 80,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Card'),
                                          content: Text('Are you sure you want to delete "${selectedCard!['shopName']}" card?'),
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
                                                    setState(() => selectedCard = null);
                                                    widget.onModalStateChanged?.call(false);
                                                  }
                                                }
                                                navigator.pop();
                                              },
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
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
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () {
                            setState(() => selectedCard = null);
                            widget.onModalStateChanged?.call(false);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
