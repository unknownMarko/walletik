import 'package:flutter/material.dart';
import 'add_card_screen.dart';
import '../widgets/loyalty_card.dart';
import '../data/mock_cards.dart';
import '../services/card_storage.dart';
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
  List<Map<String, dynamic>> cards = [];
  Map<String, dynamic>? selectedCard;

  @override
  void initState() {
    super.initState();
    _loadCards();
    widget.onCloseModalCallback?.call(closeModal);
  }
  
  Future<void> _loadCards() async {
    final loadedCards = await CardStorage.loadCards();
    setState(() {
      cards = loadedCards;
    });
  }
  
  void closeModal() {
    if (selectedCard != null) {
      setState(() {
        selectedCard = null;
      });
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
      appBar: AppBar(
        backgroundColor: selectedCard != null 
          ? Colors.black.withValues(alpha: 0.7)
          : Theme.of(context).colorScheme.surface,
        title: Text("Walletik", style: TextStyle(color: selectedCard != null 
          ? Colors.white.withValues(alpha: 0.9)
          : Theme.of(context).colorScheme.onSurface)),
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: cards.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddCardScreen()),
                    );
                    
                    if (result != null) {
                      final newCard = {
                        'shopName': result['name'],
                        'description': result['description'] ?? '',
                        'cardNumber': result['code'],
                        'color': '#0066CC', // Default blue color
                      };
                      
                      await CardStorage.addCard(newCard);
                      await _loadCards();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 36,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Card',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              final card = cards[index - 1];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCard = card;
                  });
                  widget.onModalStateChanged?.call(true);
                },
                child: LoyaltyCard(
                  shopName: card['shopName'],
                  description: card['description'],
                  cardNumber: card['cardNumber'],
                  cardColor: MockCards.hexToColor(card['color']),
                ),
              );
            },
          ),
          if (selectedCard != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedCard = null;
                });
                widget.onModalStateChanged?.call(false);
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // Prevent closing when tapping the card itself
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
                      height: 320,
                      decoration: BoxDecoration(
                        color: MockCards.hexToColor(selectedCard!['color']),
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
                                                if (selectedCard != null) {
                                                  await CardStorage.removeCard(selectedCard!);
                                                  await _loadCards();
                                                  setState(() {
                                                    selectedCard = null;
                                                  });
                                                  widget.onModalStateChanged?.call(false);
                                                }
                                                Navigator.pop(context);
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
                            setState(() {
                              selectedCard = null;
                            });
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
    );
  }
}
