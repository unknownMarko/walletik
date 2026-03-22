import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/background_logo.dart';

import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/card_provider.dart';
import '../providers/shopping_provider.dart';
import '../utils/color_utils.dart';
import '../services/data_export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    if (name != null && name.isNotEmpty) {
      setState(() => _userName = name);
    }
  }

  Future<void> _editUserName() async {
    final controller = TextEditingController(text: _userName == 'Guest' ? '' : _userName);
    final colorScheme = Theme.of(context).colorScheme;
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Edit Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Your name', hintText: 'e.g., Marko'),
                onSubmitted: (val) => Navigator.pop(sheetContext, val.trim()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', result);
      setState(() => _userName = result);
    }
  }

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
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      _userName,
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
              GestureDetector(
                onTap: _editUserName,
                child: Icon(
                  Icons.edit_rounded,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
                      ? ColorUtils.cardColor(card.color, Theme.of(context).brightness)
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

  void _showThemePicker(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final themes = [
      (AppTheme.light, 'Light', Icons.light_mode, Colors.white),
      (AppTheme.dark, 'Dark', Icons.dark_mode, const Color(0xFF121212)),
      (AppTheme.oled, 'Dark (OLED)', Icons.brightness_1, Colors.black),
      (AppTheme.purple, 'Dark Purple', Icons.color_lens, const Color(0xFF1e0a3c)),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      builder: (sheetContext) {
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
              Text(
                'Choose theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...themes.map((t) {
                final (theme, name, icon, previewColor) = t;
                final isSelected = themeProvider.theme == theme;
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: previewColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.2),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Icon(icon, size: 18, color: previewColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
                  onTap: () {
                    themeProvider.setTheme(theme);
                    Navigator.pop(sheetContext);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
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
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
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
                          color: ColorUtils.cardColor(card.color, Theme.of(context).brightness),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _buildUserCard(),
              _buildSectionHeader('Appearance'),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    subtitle: Text(themeProvider.themeName),
                    onTap: () => _showThemePicker(context, themeProvider),
                  );
                },
              ),
              _buildSectionHeader('Quick Access Cards'),
              _buildQuickAccessSettings(),
              _buildSectionHeader('Data'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final errorColor = Theme.of(context).colorScheme.error;
                          try {
                            await DataExportService.exportData();
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Export failed: $e'),
                                backgroundColor: errorColor,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
                              const SizedBox(width: 8),
                              Text('Export', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final errorColor = Theme.of(context).colorScheme.error;
                          final cardProvider = context.read<CardProvider>();
                          final shoppingProvider = context.read<ShoppingProvider>();
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Import Data'),
                              content: const Text('This will replace all current data. Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Import'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          try {
                            final summary = await DataExportService.importData();
                            cardProvider.loadCards();
                            shoppingProvider.loadItems();
                            messenger.showSnackBar(
                              SnackBar(content: Text(summary)),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Import failed: $e'),
                                backgroundColor: errorColor,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
                              const SizedBox(width: 8),
                              Text('Import', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
