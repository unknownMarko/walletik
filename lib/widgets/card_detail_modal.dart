import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/loyalty_card.dart';
import '../providers/card_provider.dart';
import '../utils/color_utils.dart';
import '../utils/barcode_utils.dart';
import '../utils/route_transitions.dart';
import '../screens/add_card_screen.dart';

class CardDetailModal extends StatefulWidget {
  final LoyaltyCard? card;
  final VoidCallback onClose;
  final Future<void> Function() onRefreshCards;
  final Function(bool)? onModalStateChanged;

  const CardDetailModal({
    super.key,
    required this.card,
    required this.onClose,
    required this.onRefreshCards,
    this.onModalStateChanged,
  });

  @override
  State<CardDetailModal> createState() => _CardDetailModalState();
}

class _CardDetailModalState extends State<CardDetailModal>
    with TickerProviderStateMixin {
  late AnimationController _modalController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _contentFadeAnimation;

  LoyaltyCard? _previousCard;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
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
  void didUpdateWidget(CardDetailModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Card became visible
    if (widget.card != null && oldWidget.card == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showModal();
      });
    }
    // Card became hidden
    else if (widget.card == null && oldWidget.card != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hideModal();
      });
    }
  }

  void _showModal() {
    setState(() {
      _isVisible = true;
      _previousCard = widget.card;
    });

    // Defer notification to avoid setState during build
    Future.microtask(() {
      if (mounted) widget.onModalStateChanged?.call(true);
    });

    _modalController.reset();
    _contentController.reset();

    _modalController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  void _hideModal() {
    _contentController.reverse();
    _modalController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _previousCard = null;
        });
        // Defer notification to avoid setState during build
        Future.microtask(() {
          if (mounted) widget.onModalStateChanged?.call(false);
        });
      }
    });
  }

  @override
  void dispose() {
    _modalController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  LoyaltyCard? get _displayCard => widget.card ?? _previousCard;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible && widget.card == null) {
      return const SizedBox.shrink();
    }

    final card = _displayCard;
    if (card == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onClose,
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
                        tag: 'card_${card.shopName}_${card.cardNumber}',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 100,
                            ),
                            height: card.barcodeFormat == 'qrCode' ? 420 : 320,
                            decoration: BoxDecoration(
                              color: ColorUtils.hexToColor(card.color),
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
                                _buildContent(card),
                                _buildCloseButton(),
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
    );
  }

  Widget _buildContent(LoyaltyCard card) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _contentFadeAnimation,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShopName(card),
              const SizedBox(height: 8),
              _buildDescription(card),
              const Spacer(),
              _buildBarcode(card),
              const SizedBox(height: 20),
              _buildActionButtons(card),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShopName(LoyaltyCard card) {
    return FadeTransition(
      opacity: _contentFadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_contentController),
        child: Text(
          card.shopName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(LoyaltyCard card) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Text(
          card.description ?? '',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBarcode(LoyaltyCard card) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Transform.scale(
        scale: Tween<double>(begin: 0.9, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: _contentController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
              ),
            )
            .value,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.string(
              BarcodeUtils.generate(card.cardNumber, card.barcodeFormat),
              width: card.barcodeFormat == 'qrCode' ? 200 : 280,
              height: card.barcodeFormat == 'qrCode' ? 200 : 80,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(LoyaltyCard card) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildEditButton(card),
            _buildDeleteButton(card),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(LoyaltyCard card) {
    return IconButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          FadeScalePageRoute(
            builder: (context) => AddCardScreen(editCard: card.toJson()),
          ),
        );

        if (result != null && result is Map<String, dynamic>) {
          final updatedCard = LoyaltyCard(
            shopName: result['name'] as String,
            description: result['description'] as String?,
            cardNumber: result['code'] as String,
            color: (result['color'] as String?) ?? card.color,
            barcodeFormat: (result['barcodeFormat'] as String?) ?? card.barcodeFormat,
            createdAt: card.createdAt,
            lastUsed: DateTime.now(),
          );

          if (mounted) {
            await context.read<CardProvider>().updateCard(card, updatedCard);
          }
          await widget.onRefreshCards();
          widget.onClose();
        }
      },
      icon: const Icon(Icons.edit, color: Colors.white70),
    );
  }

  Widget _buildDeleteButton(LoyaltyCard card) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: () => _showDeleteDialog(card),
        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showDeleteDialog(LoyaltyCard card) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text('Are you sure you want to delete ${card.shopName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await context.read<CardProvider>().deleteCard(card);
                await widget.onRefreshCards();
                navigator.pop();
                if (mounted) {
                  widget.onClose();
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Transform.scale(
          scale: Tween<double>(begin: 0.8, end: 1.0)
              .animate(
                CurvedAnimation(
                  parent: _contentController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeOutBack),
                ),
              )
              .value,
          child: IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
