import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/card_provider.dart';
import '../providers/shopping_provider.dart';
import '../utils/color_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserCard() {
    return Consumer2<CardProvider, ShoppingProvider>(
      builder: (context, cardProvider, shoppingProvider, child) {
        final cardsCount = cardProvider.cards.length;
        final itemsCount = shoppingProvider.items.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cardsCount cards • $itemsCount items',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessSettings() {
    final colorScheme = Theme.of(context).colorScheme;
    final slotLabels = ['Primary', 'Secondary', 'Third'];
    final slotIcons = [Icons.looks_one_rounded, Icons.looks_two_rounded, Icons.looks_3_rounded];

    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final slotCards = [
          cardProvider.primaryCard,
          cardProvider.secondaryCard,
          cardProvider.thirdCard,
        ];

        return Column(
          children: List.generate(3, (index) {
            final card = slotCards[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  slotIcons[index],
                  color: card != null
                      ? ColorUtils.hexToColor(card.color)
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                title: Text(
                  slotLabels[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  card?.shopName ?? 'Tap to set',
                  style: TextStyle(
                    color: card != null
                        ? colorScheme.onSurface.withValues(alpha: 0.7)
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                    fontStyle: card == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onTap: () => _showCardPicker(context, cardProvider, index),
              ),
            );
          }),
        );
      },
    );
  }

  void _showCardPicker(BuildContext context, CardProvider cardProvider, int slot) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentCards = [
      cardProvider.primaryCard,
      cardProvider.secondaryCard,
      cardProvider.thirdCard,
    ];
    final hasCard = currentCards[slot] != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final allCards = cardProvider.cards;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose a card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (hasCard)
                ListTile(
                  leading: Icon(
                    Icons.remove_circle_outline,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    'Remove',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () {
                    cardProvider.setQuickAccessCard(slot, null);
                    Navigator.pop(sheetContext);
                  },
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCards.length,
                  itemBuilder: (context, index) {
                    final card = allCards[index];
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ColorUtils.hexToColor(card.color),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      title: Text(
                        card.shopName,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        cardProvider.setQuickAccessCard(slot, card);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackgroundLogo(
      child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUserCard(),
              _buildSectionHeader('Appearance'),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme Color'),
                    subtitle: Text(themeProvider.themeName),
                    trailing: Switch(
                      value: themeProvider.isDarkTheme,
                      onChanged: (val) => themeProvider.toggleTheme(),
                    ),
                  );
                },
              ),
              _buildSectionHeader('Quick Access Cards'),
              _buildQuickAccessSettings(),
              _buildSectionHeader('About'),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('App Version'),
                subtitle: Text('0.0.1'),
              ),
            ],
          ),
      );
  }
}
