import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../widgets/card_detail_modal.dart';
import '../models/loyalty_card.dart';
import '../services/card_storage.dart';
import '../utils/color_utils.dart';
import 'add_card_screen.dart';

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
  List<LoyaltyCard> cards = [];
  List<LoyaltyCard> recentCards = [];
  List<LoyaltyCard> favoriteCards = [];
  LoyaltyCard? selectedCard;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loadedCards = await CardStorage.loadCards();
    setState(() {
      cards = loadedCards;
      recentCards = loadedCards.take(3).toList();
      favoriteCards = loadedCards
          .where((card) => card.isFavorite)
          .take(3)
          .toList();
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

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.wallet,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Cards',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cards.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                        category: (result['category'] as String?) ?? 'Other',
                        isFavorite: (result['isFavorite'] as bool?) ?? false,
                        createdAt: DateTime.now(),
                        lastUsed: DateTime.now(),
                      );

                      await CardStorage.addCard(newCard);
                      await _loadCards();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onNavigateToCards?.call(1),
                  icon: const Icon(Icons.view_list),
                  label: const Text('View All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCards() {
    if (favoriteCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Favorite Cards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favoriteCards.length,
              itemBuilder: (context, index) {
                final card = favoriteCards[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < favoriteCards.length - 1 ? 12 : 0,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCards() {
    if (recentCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Cards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (cards.length > 3)
                TextButton(
                  onPressed: () => widget.onNavigateToCards?.call(1),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentCards.length,
              itemBuilder: (context, index) {
                final card = recentCards[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < recentCards.length - 1 ? 12 : 0,
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
                );
              },
            ),
          ),
        ],
      ),
    );
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
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
                          _buildStatsCard(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildFavoriteCards(),
                          if (favoriteCards.isNotEmpty)
                            const SizedBox(height: 24),
                          _buildRecentCards(),
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
