import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/background_logo.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../widgets/card_detail_modal.dart';
import '../models/loyalty_card.dart';
import '../providers/card_provider.dart';
import '../providers/shopping_provider.dart';
import '../screens/add_card_screen.dart';
import '../utils/barcode_utils.dart';
import '../utils/color_utils.dart';
import '../utils/route_transitions.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToCards;
  final Function(bool)? onModalStateChanged;

  const HomeScreen({
    super.key,
    this.onNavigateToCards,
    this.onModalStateChanged,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  LoyaltyCard? selectedCard;

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

  Widget _buildQuickAccessCards(CardProvider cardProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = cardProvider.primaryCard;
    final secondary = cardProvider.secondaryCard;
    final third = cardProvider.thirdCard;

    final hasAny = primary != null || secondary != null || third != null;
    if (!hasAny) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Primary card — large with barcode
          if (primary != null)
            _buildPrimaryQuickCard(primary, colorScheme)
          else
            _buildEmptySlotPlaceholder(colorScheme, height: 160),
          const SizedBox(height: 12),
          // Secondary + Third — side by side smaller cards
          if (secondary != null || third != null)
            Row(
              children: [
                Expanded(
                  child: secondary != null
                      ? GestureDetector(
                          onTap: () => _showCardDetail(secondary, 0),
                          child: SizedBox(
                            height: 155,
                            child: card_widget.LoyaltyCard(
                              shopName: secondary.shopName,
                              description: secondary.description ?? '',
                              cardNumber: secondary.cardNumber,
                              cardColor: ColorUtils.hexToColor(secondary.color),
                            ),
                          ),
                        )
                      : _buildEmptySlotPlaceholder(colorScheme, height: 80),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: third != null
                      ? GestureDetector(
                          onTap: () => _showCardDetail(third, 0),
                          child: SizedBox(
                            height: 155,
                            child: card_widget.LoyaltyCard(
                              shopName: third.shopName,
                              description: third.description ?? '',
                              cardNumber: third.cardNumber,
                              cardColor: ColorUtils.hexToColor(third.color),
                            ),
                          ),
                        )
                      : _buildEmptySlotPlaceholder(colorScheme, height: 80),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPrimaryQuickCard(LoyaltyCard card, ColorScheme colorScheme) {
    final cardColor = ColorUtils.hexToColor(card.color);
    final isQr = card.barcodeFormat == 'qrCode';

    return GestureDetector(
      onTap: () => _showCardDetail(card, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.shopName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: EdgeInsets.all(isQr ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.string(
                  BarcodeUtils.generate(card.cardNumber, card.barcodeFormat),
                  width: isQr ? 120 : double.infinity,
                  height: isQr ? 120 : 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                card.cardNumber,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlotPlaceholder(ColorScheme colorScheme, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Set in Settings',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingPreview() {
    final colorScheme = Theme.of(context).colorScheme;
    final shoppingProvider = context.watch<ShoppingProvider>();
    final pendingCount = shoppingProvider.pendingItems.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => widget.onNavigateToCards?.call(2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  pendingCount == 0
                      ? 'Shopping list is empty'
                      : '$pendingCount item${pendingCount == 1 ? '' : 's'} on your list',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.credit_card_outlined,
              size: 44,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No cards yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first loyalty card to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Map<String, dynamic>>(
                FadeScalePageRoute(
                  builder: (context) => const AddCardScreen(),
                ),
              );
              if (result != null && mounted) {
                context.read<CardProvider>().loadCards();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Add Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();
    final cards = cardProvider.cards;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BackgroundLogo(
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
                        // 1. Header — kept exactly as-is
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
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
                              IconButton(
                                onPressed: () =>
                                    widget.onNavigateToCards?.call(3),
                                icon: const Icon(Icons.person_sharp),
                                iconSize: 28,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (cards.isEmpty) ...[
                          // 6. Empty state
                          _buildEmptyState(),
                        ] else ...[
                          // 3. Quick access cards
                          _buildQuickAccessCards(cardProvider),
                          // 4. Shopping list preview
                          _buildShoppingPreview(),
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            CardDetailModal(
              card: selectedCard,
              onClose: closeModal,
              onRefreshCards: () => cardProvider.loadCards(),
              onModalStateChanged: widget.onModalStateChanged,
            ),
          ],
        ),
      ),
    );
  }
}
