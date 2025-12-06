import 'package:flutter/material.dart';
import 'dart:async';
import 'add_card_screen.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../models/loyalty_card.dart';
import '../widgets/background_logo.dart';
import '../services/card_storage.dart';
import '../utils/color_utils.dart';
import '../utils/route_transitions.dart';
import '../utils/barcode_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardsScreen extends StatefulWidget {
  final Function(bool)? onModalStateChanged;

  const CardsScreen({super.key, this.onModalStateChanged});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<LoyaltyCard> allCards = [];
  List<LoyaltyCard> filteredCards = [];
  List<LoyaltyCard> displayCards = [];
  LoyaltyCard? selectedCard;
  int? selectedCardIndex;
  LoyaltyCard? draggingCard;
  int? hoverIndex;
  Timer? _previewTimer;

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
    _searchController.addListener(_filterCards);

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
    ).animate(CurvedAnimation(parent: _modalController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _modalController, curve: Curves.easeOutCubic),
        );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _modalController.dispose();
    _contentController.dispose();
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

  void _showCardDetail(LoyaltyCard card, int index) {
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
              if (selectedCard != null)
                GestureDetector(
                  onTap: closeModal,
                  child: AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Container(
                        color: Colors.black.withValues(
                          alpha: _backgroundAnimation.value,
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _modalController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Hero(
                                    tag:
                                        'card_${selectedCard!.shopName}_${selectedCard!.cardNumber}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 100,
                                        ),
                                        height: 320,
                                        decoration: BoxDecoration(
                                          color: ColorUtils.hexToColor(
                                            selectedCard!.color,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
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
                                                animation:
                                                    _contentFadeAnimation,
                                                builder: (context, child) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      FadeTransition(
                                                        opacity:
                                                            _contentFadeAnimation,
                                                        child: SlideTransition(
                                                          position:
                                                              Tween<Offset>(
                                                                begin:
                                                                    const Offset(
                                                                      0,
                                                                      0.1,
                                                                    ),
                                                                end:
                                                                    Offset.zero,
                                                              ).animate(
                                                                _contentController,
                                                              ),
                                                          child: Text(
                                                            selectedCard!.shopName,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      FadeTransition(
                                                        opacity:
                                                            Tween<double>(
                                                              begin: 0.0,
                                                              end: 1.0,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    _contentController,
                                                                curve: const Interval(
                                                                  0.3,
                                                                  1.0,
                                                                  curve: Curves
                                                                      .easeOut,
                                                                ),
                                                              ),
                                                            ),
                                                        child: SlideTransition(
                                                          position:
                                                              Tween<Offset>(
                                                                begin:
                                                                    const Offset(
                                                                      0,
                                                                      0.1,
                                                                    ),
                                                                end:
                                                                    Offset.zero,
                                                              ).animate(
                                                                CurvedAnimation(
                                                                  parent:
                                                                      _contentController,
                                                                  curve: const Interval(
                                                                    0.3,
                                                                    1.0,
                                                                    curve: Curves
                                                                        .easeOut,
                                                                  ),
                                                                ),
                                                              ),
                                                          child: Text(
                                                            selectedCard!.description ?? '',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 16,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      FadeTransition(
                                                        opacity:
                                                            Tween<double>(
                                                              begin: 0.0,
                                                              end: 1.0,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    _contentController,
                                                                curve: const Interval(
                                                                  0.5,
                                                                  1.0,
                                                                  curve: Curves
                                                                      .easeOut,
                                                                ),
                                                              ),
                                                            ),
                                                        child: Transform.scale(
                                                          scale: Tween<double>(begin: 0.9, end: 1.0)
                                                              .animate(
                                                                CurvedAnimation(
                                                                  parent:
                                                                      _contentController,
                                                                  curve: const Interval(
                                                                    0.5,
                                                                    1.0,
                                                                    curve: Curves
                                                                        .easeOutBack,
                                                                  ),
                                                                ),
                                                              )
                                                              .value,
                                                          child: Center(
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                              child: SvgPicture.string(
                                                                BarcodeUtils.generate(
                                                                  selectedCard!.cardNumber,
                                                                  selectedCard!.barcodeFormat,
                                                                ),
                                                                width:
                                                                    selectedCard!.barcodeFormat ==
                                                                        'qrCode'
                                                                    ? 200
                                                                    : 280,
                                                                height:
                                                                    selectedCard!.barcodeFormat ==
                                                                        'qrCode'
                                                                    ? 200
                                                                    : 80,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      FadeTransition(
                                                        opacity:
                                                            Tween<double>(
                                                              begin: 0.0,
                                                              end: 1.0,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    _contentController,
                                                                curve: const Interval(
                                                                  0.7,
                                                                  1.0,
                                                                  curve: Curves
                                                                      .easeOut,
                                                                ),
                                                              ),
                                                            ),
                                                        child: SlideTransition(
                                                          position:
                                                              Tween<Offset>(
                                                                begin:
                                                                    const Offset(
                                                                      0,
                                                                      0.2,
                                                                    ),
                                                                end:
                                                                    Offset.zero,
                                                              ).animate(
                                                                CurvedAnimation(
                                                                  parent:
                                                                      _contentController,
                                                                  curve: const Interval(
                                                                    0.7,
                                                                    1.0,
                                                                    curve: Curves
                                                                        .easeOut,
                                                                  ),
                                                                ),
                                                              ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () async {
                                                                  await CardStorage.toggleFavorite(
                                                                    selectedCard!,
                                                                  );
                                                                  await _loadCards();
                                                                },
                                                                icon: Icon(
                                                                  selectedCard!.isFavorite
                                                                      ? Icons
                                                                            .star
                                                                      : Icons
                                                                            .star_border,
                                                                  color:
                                                                      selectedCard!.isFavorite
                                                                      ? Colors
                                                                            .amber
                                                                      : Colors
                                                                            .white70,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () async {
                                                                  final result = await Navigator.push(
                                                                    context,
                                                                    FadeScalePageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) => AddCardScreen(
                                                                            editCard:
                                                                                selectedCard!.toJson(),
                                                                          ),
                                                                    ),
                                                                  );

                                                                  if (result !=
                                                                          null &&
                                                                      result
                                                                          is Map<
                                                                            String,
                                                                            dynamic
                                                                          >) {
                                                                    final updatedCard = LoyaltyCard(
                                                                      shopName: result['name'] as String,
                                                                      description: result['description'] as String?,
                                                                      cardNumber: result['code'] as String,
                                                                      color: (result['color'] as String?) ?? selectedCard!.color,
                                                                      barcodeFormat: (result['barcodeFormat'] as String?) ?? selectedCard!.barcodeFormat,
                                                                      category: (result['category'] as String?) ?? selectedCard!.category,
                                                                      isFavorite: (result['isFavorite'] as bool?) ?? selectedCard!.isFavorite,
                                                                      createdAt: selectedCard!.createdAt,
                                                                      lastUsed: DateTime.now(),
                                                                    );

                                                                    await CardStorage.updateCard(
                                                                      selectedCard!,
                                                                      updatedCard,
                                                                    );
                                                                    await _loadCards();
                                                                    closeModal();
                                                                  }
                                                                },
                                                                icon: const Icon(
                                                                  Icons.edit,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        20,
                                                                      ),
                                                                ),
                                                                child: IconButton(
                                                                  onPressed: () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (
                                                                            BuildContext
                                                                            context,
                                                                          ) {
                                                                            return AlertDialog(
                                                                              title: const Text(
                                                                                'Delete Card',
                                                                              ),
                                                                              content: Text(
                                                                                'Are you sure you want to delete ${selectedCard!.shopName}?',
                                                                              ),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.pop(
                                                                                    context,
                                                                                  ),
                                                                                  child: Text(
                                                                                    'Cancel',
                                                                                    style: TextStyle(
                                                                                      color: Theme.of(
                                                                                        context,
                                                                                      ).colorScheme.onSurface,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () async {
                                                                                    final navigator = Navigator.of(
                                                                                      context,
                                                                                    );
                                                                                    if (selectedCard !=
                                                                                        null) {
                                                                                      await CardStorage.removeCard(
                                                                                        selectedCard!,
                                                                                      );
                                                                                      await _loadCards();
                                                                                      if (mounted) {
                                                                                        closeModal();
                                                                                      }
                                                                                    }
                                                                                    navigator.pop();
                                                                                  },
                                                                                  child: const Text(
                                                                                    'Delete',
                                                                                    style: TextStyle(
                                                                                      color: Colors.red,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20,
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
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
                                                opacity:
                                                    Tween<double>(
                                                      begin: 0.0,
                                                      end: 1.0,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent:
                                                            _contentController,
                                                        curve: const Interval(
                                                          0.8,
                                                          1.0,
                                                          curve: Curves.easeOut,
                                                        ),
                                                      ),
                                                    ),
                                                child: Transform.scale(
                                                  scale:
                                                      Tween<double>(
                                                            begin: 0.8,
                                                            end: 1.0,
                                                          )
                                                          .animate(
                                                            CurvedAnimation(
                                                              parent:
                                                                  _contentController,
                                                              curve: const Interval(
                                                                0.8,
                                                                1.0,
                                                                curve: Curves
                                                                    .easeOutBack,
                                                              ),
                                                            ),
                                                          )
                                                          .value,
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