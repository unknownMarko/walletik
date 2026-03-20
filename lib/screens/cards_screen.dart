import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';
import 'package:provider/provider.dart';

import 'add_card_screen.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../models/loyalty_card.dart';
import '../providers/card_provider.dart';
import '../utils/color_utils.dart';

class CardsScreen extends StatefulWidget {
  final Function(LoyaltyCard)? onCardTap;

  const CardsScreen({super.key, this.onCardTap});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  List<LoyaltyCard> filteredCards = [];
  List<LoyaltyCard> displayCards = [];
  List<LoyaltyCard> _lastProviderCards = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCards);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cards = context.read<CardProvider>().cards;
    if (cards != _lastProviderCards) {
      _lastProviderCards = cards;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _filterCards();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onCardReorder(int fromIndex, int toIndex, CardProvider provider) async {
    final allCards = List<LoyaltyCard>.from(provider.cards);
    final card = filteredCards.removeAt(fromIndex);
    filteredCards.insert(toIndex, card);

    final cardIndex = allCards.indexWhere((c) =>
      c.shopName == card.shopName && c.cardNumber == card.cardNumber);
    if (cardIndex != -1) {
      allCards.removeAt(cardIndex);
      allCards.insert(toIndex.clamp(0, allCards.length), card);
    }

    setState(() {
      displayCards = List.from(filteredCards);
    });

    await provider.reorderCards(allCards);
  }

  void _filterCards() {
    final allCards = _lastProviderCards;
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCards = List.from(allCards);
      } else {
        filteredCards = allCards.where((card) {
          final shopName = card.shopName.toLowerCase();
          final description = (card.description ?? '').toLowerCase();
          final cardNumber = card.cardNumber.toLowerCase();
          return shopName.contains(query) ||
              description.contains(query) ||
              cardNumber.contains(query);
        }).toList();
      }
      displayCards = List.from(filteredCards);
    });
  }



  void _showCardDetail(LoyaltyCard card, int index) {
    widget.onCardTap?.call(card);
  }

  Future<void> _addCard(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCardScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final newCard = LoyaltyCard(
        shopName: result['name'] as String,
        description: result['description'] as String?,
        cardNumber: result['code'] as String,
        color: (result['color'] as String?) ?? '#0066CC',
        barcodeFormat: (result['barcodeFormat'] as String?) ?? 'code128',
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      if (mounted) {
        await context.read<CardProvider>().addCard(newCard);
      }
    }
  }

  Widget _buildCardItem(LoyaltyCard card, int index) {
    return GestureDetector(
      onTap: () => _showCardDetail(card, index),
      child: card_widget.LoyaltyCard(
        shopName: card.shopName,
        description: card.description ?? '',
        cardNumber: card.cardNumber,
        cardColor: ColorUtils.hexToColor(card.color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.select<CardProvider, List<LoyaltyCard>>((p) => p.cards);

    return BackgroundLogo(
      child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search cards...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _addCard(context),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: (displayCards.length + 1) ~/ 2,
                    itemBuilder: (context, rowIndex) {
                      final leftIndex = rowIndex * 2;
                      final rightIndex = leftIndex + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 100,
                                child: _buildCardItem(displayCards[leftIndex], leftIndex),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: rightIndex < displayCards.length
                                  ? SizedBox(
                                      height: 100,
                                      child: _buildCardItem(displayCards[rightIndex], rightIndex),
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
          ),
      );
  }
}
