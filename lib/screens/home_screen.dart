import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_logo.dart';
import '../widgets/loyalty_card.dart' as card_widget;
import '../widgets/card_detail_modal.dart';
import '../models/loyalty_card.dart';
import '../providers/card_provider.dart';
import '../utils/color_utils.dart';

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

  Widget _buildFavoriteCards(List<LoyaltyCard> favoriteCards) {
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
                  key: ValueKey('fav_${card.shopName}_${card.cardNumber}'),
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < favoriteCards.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _showCardDetail(card, index),
                    child: Hero(
                      tag: 'fav_card_${card.shopName}_${card.cardNumber}',
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

  Widget _buildRecentCards(List<LoyaltyCard> recentCards, int totalCount) {
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
              if (totalCount > 3)
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
                  key: ValueKey('recent_${card.shopName}_${card.cardNumber}'),
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < recentCards.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _showCardDetail(card, index),
                    child: Hero(
                      tag: 'recent_card_${card.shopName}_${card.cardNumber}',
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
    final cardProvider = context.watch<CardProvider>();
    final cards = cardProvider.cards;
    final recentCards = cardProvider.recentCards;
    final favoriteCards = cardProvider.favoriteCards;

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
                          _buildFavoriteCards(favoriteCards),
                          if (favoriteCards.isNotEmpty)
                            const SizedBox(height: 24),
                          _buildRecentCards(recentCards, cards.length),
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
