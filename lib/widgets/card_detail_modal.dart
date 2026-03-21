import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/loyalty_card.dart';
import '../providers/card_provider.dart';
import '../utils/color_utils.dart';
import '../utils/barcode_utils.dart';
import '../screens/add_card_screen.dart';
import 'loyalty_card.dart' show GrainOverlay;

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  LoyaltyCard? _previousCard;
  bool _isVisible = false;

  // Cached values to avoid recomputation during animation
  String? _cachedBarcodeSvg;
  Color? _cachedCardColor;
  String? _cachedCardKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  void _updateCache(LoyaltyCard card) {
    final key = '${card.cardNumber}_${card.barcodeFormat}_${card.color}';
    if (_cachedCardKey != key) {
      _cachedCardKey = key;
      _cachedBarcodeSvg = BarcodeUtils.generate(card.cardNumber, card.barcodeFormat);
      _cachedCardColor = ColorUtils.hexToColor(card.color);
    }
  }

  @override
  void didUpdateWidget(CardDetailModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card != null && oldWidget.card == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showModal();
      });
    } else if (widget.card == null && oldWidget.card != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hideModal();
      });
    }
  }

  void _showModal() {
    _updateCache(widget.card!);
    setState(() {
      _isVisible = true;
      _previousCard = widget.card;
    });
    Future.microtask(() {
      if (mounted) widget.onModalStateChanged?.call(true);
    });
    _controller.forward(from: 0);
  }

  void _hideModal() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _previousCard = null;
          _cachedCardKey = null;
          _cachedBarcodeSvg = null;
          _cachedCardColor = null;
        });
        Future.microtask(() {
          if (mounted) widget.onModalStateChanged?.call(false);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LoyaltyCard? get _displayCard => widget.card ?? _previousCard;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible && widget.card == null) return const SizedBox.shrink();
    final card = _displayCard;
    if (card == null) return const SizedBox.shrink();

    _updateCache(card);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onClose,
          child: ColoredBox(
            color: Color.fromRGBO(0, 0, 0, _backgroundAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
      child: _buildCard(card),
    );
  }

  Widget _buildCard(LoyaltyCard card) {
    return GestureDetector(
      onTap: () {},
      child: Material(
        type: MaterialType.transparency,
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(_cachedCardColor, Colors.white, 0.08)!,
              _cachedCardColor!,
              Color.lerp(_cachedCardColor, Colors.black, 0.15)!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          
        ),
        child: Stack(
          children: [
            const GrainOverlay(),
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(card),
                    Divider(
                      height: 16,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildBarcode(card),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(LoyaltyCard card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
      children: [
        Expanded(
          child: Text(
            card.shopName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () async {
            final result = await AddCardScreen.show(context, editCard: card.toJson());
            if (result != null) {
              final updatedCard = LoyaltyCard(
                id: card.id,
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
          child: const Icon(Icons.edit, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () => _showDeleteDialog(card),
          child: const Icon(Icons.delete, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: widget.onClose,
          child: const Icon(Icons.close, color: Colors.white70, size: 22),
        ),
      ],
    ),
    );
  }

  Widget _buildBarcode(LoyaltyCard card) {
    if (_cachedBarcodeSvg == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.string(
        _cachedBarcodeSvg!,
        width: double.infinity,
          height: card.barcodeFormat == 'qrCode' ? 180 : 70,
        fit: BoxFit.contain,
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
}
