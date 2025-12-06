import 'package:flutter/material.dart';
import 'dart:async';
import 'add_card_screen.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../widgets/card_detail_modal.dart';
import '../models/loyalty_card.dart';
import '../widgets/background_logo.dart';
import '../services/card_storage.dart';
import '../utils/color_utils.dart';

class CardsScreen extends StatefulWidget {
  final Function(bool)? onModalStateChanged;

  const CardsScreen({super.key, this.onModalStateChanged});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LoyaltyCard> allCards = [];
  List<LoyaltyCard> filteredCards = [];
  List<LoyaltyCard> displayCards = [];
  LoyaltyCard? selectedCard;
  LoyaltyCard? draggingCard;
  int? hoverIndex;
  Timer? _previewTimer;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _previewTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final loadedCards = await CardStorage.loadCards();
    setState(() {
      allCards = loadedCards;
      filteredCards = loadedCards;
      displayCards = List.from(loadedCards);
    });
  }

  Future<void> _onCardReorder(int fromIndex, int toIndex) async {
    setState(() {
      final card = filteredCards.removeAt(fromIndex);
      filteredCards.insert(toIndex, card);

      final cardIndex = allCards.indexWhere((c) =>
        c.shopName == card.shopName && c.cardNumber == card.cardNumber);
      if (cardIndex != -1) {
        allCards.removeAt(cardIndex);
        allCards.insert(toIndex.clamp(0, allCards.length), card);
      }

      displayCards = List.from(filteredCards);
    });

    await CardStorage.saveCards(allCards);
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCards = allCards;
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

  void _updatePreviewOrder(LoyaltyCard draggedCard, int targetIndex) {
    setState(() {
      final draggedIndex = filteredCards.indexWhere((c) =>
        c.shopName == draggedCard.shopName && c.cardNumber == draggedCard.cardNumber);

      if (draggedIndex != -1) {
        displayCards = List.from(filteredCards);
        final card = displayCards.removeAt(draggedIndex);
        displayCards.insert(targetIndex, card);
        draggingCard = draggedCard;
        hoverIndex = targetIndex;
      }
    });
  }

  void _resetPreview() {
    _previewTimer?.cancel();
    _previewTimer = null;
    setState(() {
      displayCards = List.from(filteredCards);
      draggingCard = null;
      hoverIndex = null;
    });
  }

  void _startPreviewTimer(LoyaltyCard draggedCard, int targetIndex) {
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 150), () {
      _updatePreviewOrder(draggedCard, targetIndex);
    });
  }

  void closeModal() {
    setState(() {
      selectedCard = null;
    });
  }

  void _showCardDetail(LoyaltyCard card, int index) {
    setState(() {
      selectedCard = card;
    });
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
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: displayCards.length + 1,
                      itemBuilder: (context, index) {
                        if (index == displayCards.length) {
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddCardScreen(),
                                ),
                              );

                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                final newCard = LoyaltyCard(
                                  shopName: result['name'] as String,
                                  description: result['description'] as String?,
                                  cardNumber: result['code'] as String,
                                  color: (result['color'] as String?) ?? '#0066CC',
                                  barcodeFormat: (result['barcodeFormat'] as String?) ?? 'code128',
                                  category: (result['category'] as String?) ?? 'Other',
                                  isFavorite: (result['isFavorite'] as bool?) ?? false,
                                  createdAt: DateTime.now(),
                                  lastUsed: DateTime.now(),
                                );

                                await CardStorage.addCard(newCard);
                                await _loadCards();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.outline,
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Card',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          final card = displayCards[index];
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: DragTarget<LoyaltyCard>(
                              key: ValueKey('${card.shopName}_${card.cardNumber}_$index'),
                            onWillAcceptWithDetails: (details) => details.data != card,
                            onMove: (details) {
                              _startPreviewTimer(details.data, index);
                            },
                            onLeave: (data) {
                              _resetPreview();
                            },
                            onAcceptWithDetails: (details) {
                              final draggedCard = details.data;
                              final fromIndex = filteredCards.indexWhere((c) =>
                                c.shopName == draggedCard.shopName &&
                                c.cardNumber == draggedCard.cardNumber);
                              if (fromIndex != -1) {
                                _onCardReorder(fromIndex, index);
                              }
                              _resetPreview();
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isHovering = candidateData.isNotEmpty;
                              return AnimatedScale(
                                scale: isHovering ? 0.97 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  transform: isHovering ? Matrix4.translationValues(0, -5, 0) : Matrix4.identity(),
                                  child: LongPressDraggable<LoyaltyCard>(
                                data: card,
                                feedback: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 150,
                                    height: 125,
                                    decoration: BoxDecoration(
                                      color: ColorUtils.hexToColor(card.color),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Opacity(
                                      opacity: 0.9,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              card.shopName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              card.cardNumber,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.drag_indicator,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                      size: 32,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => _showCardDetail(card, index),
                                  child: Hero(
                                    tag: 'card_${card.shopName}_${card.cardNumber}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: card_widget.LoyaltyCard(
                                        shopName: card.shopName,
                                        description: card.description ?? '',
                                        cardNumber: card.cardNumber,
                                        cardColor: ColorUtils.hexToColor(card.color),
                                        category: card.category,
                                        isFavorite: card.isFavorite,
                                      ),
                                    ),
                                  ),
                                ),
                                  ),
                                ),
                              );
                            },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              CardDetailModal(
                card: selectedCard,
                onClose: closeModal,
                onRefreshCards: _loadCards,
                onModalStateChanged: widget.onModalStateChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}