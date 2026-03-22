import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/background_logo.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

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
  final ScrollController _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<LoyaltyCard> _filterCards(List<LoyaltyCard> allCards) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return allCards;
    return allCards.where((card) {
      final shopName = card.shopName.toLowerCase();
      final description = (card.description ?? '').toLowerCase();
      final cardNumber = card.cardNumber.toLowerCase();
      return shopName.contains(query) ||
          description.contains(query) ||
          cardNumber.contains(query);
    }).toList();
  }

  void _showCardDetail(LoyaltyCard card, int index) {
    HapticFeedback.lightImpact();
    widget.onCardTap?.call(card);
  }

  Future<void> _addCard(BuildContext context) async {
    final cardProvider = context.read<CardProvider>();
    final result = await AddCardScreen.show(context);

    if (result != null && mounted) {
      final newCard = LoyaltyCard(
        shopName: result['name'] as String,
        description: result['description'] as String?,
        cardNumber: result['code'] as String,
        color: (result['color'] as String?) ?? '#0066CC',
        barcodeFormat: (result['barcodeFormat'] as String?) ?? 'code128',
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      await cardProvider.addCard(newCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<CardProvider>();
    final allCards = provider.cards;
    final displayCards = _filterCards(allCards);

    // Fix #5: Error SnackBar
    final cardError = provider.error;
    if (cardError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CardProvider>().clearError();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cardError),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });
    }

    final generatedChildren = List.generate(
      displayCards.length,
      (index) {
        final card = displayCards[index];
        return SizedBox(
          key: Key(card.id ?? '${card.shopName}_${card.cardNumber}'),
          height: 100,
          child: GestureDetector(
            onTap: () => _showCardDetail(card, index),
            child: card_widget.LoyaltyCard(
              shopName: card.shopName,
              description: card.description ?? '',
              cardNumber: card.cardNumber,
              cardColor: ColorUtils.hexToColor(card.color),
            ),
          ),
        );
      },
    );

    return BackgroundLogo(
      child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  height: 48,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                ),
                                const card_widget.GrainOverlay(opacity: 0.5),
                                TextField(
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
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _addCard(context),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                const card_widget.GrainOverlay(opacity: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: displayCards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No cards found'
                                  : 'No cards yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tap Add to create your first card',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ReorderableBuilder(
                    scrollController: _scrollController,
                    enableDraggable: _searchController.text.isEmpty,
                    dragChildBoxDecoration: const BoxDecoration(),
                    onReorder: (ReorderedListFunction reorderedListFunction) {
                      final reordered = reorderedListFunction(displayCards) as List<LoyaltyCard>;
                      provider.reorderCards(reordered);
                    },
                    children: generatedChildren,
                    builder: (children) {
                      return GridView(
                        key: _gridViewKey,
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.7,
                        ),
                        children: children,
                      );
                    },
                  ),
                ),
              ],
          ),
      );
  }
}
