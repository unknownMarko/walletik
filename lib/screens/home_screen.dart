import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/background_logo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../models/loyalty_card.dart';
import '../models/shopping_item.dart';
import '../providers/card_provider.dart';
import '../providers/shopping_provider.dart';
import '../screens/add_card_screen.dart';
import '../utils/barcode_utils.dart';
import '../utils/color_utils.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToCards;
  final Function(LoyaltyCard)? onCardTap;

  const HomeScreen({
    super.key,
    this.onNavigateToCards,
    this.onCardTap,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Barcode SVG cache
  String? _cachedBarcodeSvg;
  String? _cachedBarcodeKey;

  String _getBarcodeSvg(String cardNumber, String barcodeFormat) {
    final key = '${cardNumber}_$barcodeFormat';
    if (_cachedBarcodeKey != key) {
      _cachedBarcodeKey = key;
      _cachedBarcodeSvg = BarcodeUtils.generate(cardNumber, barcodeFormat);
    }
    return _cachedBarcodeSvg!;
  }

  void _showCardDetail(LoyaltyCard card, int index) {
    HapticFeedback.lightImpact();
    widget.onCardTap?.call(card);
  }

  Widget _buildQuickAccessCards(LoyaltyCard? primary, LoyaltyCard? secondary, LoyaltyCard? third) {
    final colorScheme = Theme.of(context).colorScheme;

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
                            height: 100,
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
                            height: 100,
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
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(cardColor, Colors.white, 0.08)!,
              cardColor,
              Color.lerp(cardColor, Colors.black, 0.15)!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
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
                        _getBarcodeSvg(card.cardNumber, card.barcodeFormat),
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
            ],
          ),
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
    final pendingItems = context.select<ShoppingProvider, List<ShoppingItem>>((p) => p.pendingItems);
    final previewItems = pendingItems.take(3).toList();
    final remaining = pendingItems.length - previewItems.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => widget.onNavigateToCards?.call(2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shopping list',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (pendingItems.isNotEmpty)
                    Text(
                      '${pendingItems.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
              if (pendingItems.isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'All done! No pending items.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                ...previewItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.quantity > 1 ? '${item.quantity}x ${item.name}' : item.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
                if (remaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '+$remaining more',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Getting started steps
          _buildOnboardingStep(
            icon: Icons.credit_card_rounded,
            title: 'Add your loyalty cards',
            subtitle: 'Scan barcode or enter manually',
            color: colorScheme.primary,
            onTap: () async {
              final result = await AddCardScreen.show(context);
              if (result != null && mounted) {
                final provider = context.read<CardProvider>();
                final newCard = LoyaltyCard(
                  shopName: result['name'] as String,
                  cardNumber: result['code'] as String,
                  description: result['description'] as String?,
                  color: (result['color'] as String?) ?? '#0066CC',
                  barcodeFormat: (result['barcodeFormat'] as String?) ?? 'code128',
                  createdAt: DateTime.now(),
                  lastUsed: DateTime.now(),
                );
                await provider.addCard(newCard);
              }
            },
          ),
          const SizedBox(height: 10),
          _buildOnboardingStep(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Quick access from home',
            subtitle: 'Set your most used cards for instant scanning',
            color: Colors.orange.shade700,
            onTap: null,
          ),
          const SizedBox(height: 10),
          _buildOnboardingStep(
            icon: Icons.shopping_cart_rounded,
            title: 'Shopping list built-in',
            subtitle: 'Swipe left to delete, right to edit, tap to check off',
            color: Colors.teal,
            onTap: () => widget.onNavigateToCards?.call(2),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cards = context.select<CardProvider, List<LoyaltyCard>>((p) => p.cards);
    final primaryCard = context.select<CardProvider, LoyaltyCard?>((p) => p.primaryCard);
    final secondaryCard = context.select<CardProvider, LoyaltyCard?>((p) => p.secondaryCard);
    final thirdCard = context.select<CardProvider, LoyaltyCard?>((p) => p.thirdCard);
    final cardError = context.select<CardProvider, String?>((p) => p.error);

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

    return BackgroundLogo(
      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          _buildQuickAccessCards(primaryCard, secondaryCard, thirdCard),
                          // 4. Shopping list preview
                          _buildShoppingPreview(),
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                   ),
      );
  }
}
