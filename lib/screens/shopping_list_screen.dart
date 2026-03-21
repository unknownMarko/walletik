import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';
import '../widgets/loyalty_card.dart' show GrainOverlay;
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _quickAddController = TextEditingController();

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

  Future<void> _onReorder(int oldIndex, int newIndex, ShoppingProvider provider) async {
    final items = List<ShoppingItem>.from(provider.items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    await provider.reorderItems(items);
  }

  Future<void> _toggleItemCompletion(ShoppingItem item, ShoppingProvider provider) async {
    await provider.toggleCompletion(item);
  }

  Future<void> _deleteItem(ShoppingItem item, ShoppingProvider provider) async {
    await provider.deleteItem(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await provider.addItem(item);
            },
          ),
        ),
      );
    }
  }

  Future<void> _quickAdd(ShoppingProvider provider) async {
    final name = _quickAddController.text.trim();
    if (name.isEmpty) return;
    final item = ShoppingItem(
      id: '',
      name: name,
      quantity: 1,
      category: 'Groceries',
      createdAt: DateTime.now(),
    );
    await provider.addItem(item);
    _quickAddController.clear();
  }

  Future<void> _showEditDialog(ShoppingProvider provider, ShoppingItem item) async {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet<ShoppingItem>(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Edit Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Milk, Bread',
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setQuantityState) {
                  int qty = int.tryParse(quantityController.text) ?? 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (qty > 1) {
                            setQuantityState(() {
                              quantityController.text = (qty - 1).toString();
                            });
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 20,
                            color: qty > 1
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          qty.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (qty < 99) {
                            setQuantityState(() {
                              quantityController.text = (qty + 1).toString();
                            });
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('Please enter an item name')),
                          );
                          return;
                        }
                        final updated = ShoppingItem(
                          id: item.id,
                          name: nameController.text.trim(),
                          quantity: int.tryParse(quantityController.text) ?? 1,
                          category: item.category,
                          isCompleted: item.isCompleted,
                          createdAt: item.createdAt,
                        );
                        Navigator.pop(sheetContext, updated);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await provider.updateItem(item, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allItems = context.select<ShoppingProvider, List<ShoppingItem>>((p) => p.items);
    final shoppingError = context.select<ShoppingProvider, String?>((p) => p.error);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    if (shoppingError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ShoppingProvider>().clearError();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(shoppingError),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });
    }

    return BackgroundLogo(
      child: Column(
            children: [
              Expanded(
                child: allItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: isDarkTheme ? Colors.white30 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your shopping list is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDarkTheme ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type above to add your first item',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkTheme ? Colors.white54 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: allItems.length,
                        onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, context.read<ShoppingProvider>()),
                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              final double animValue = Curves.easeInOut.transform(animation.value);
                              final double elevation = lerpDouble(0, 0, animValue)!;
                              final double scale = lerpDouble(1, 1.05, animValue)!;
                              
                              return Transform.scale(
                                scale: scale,
                                child: Material(
                                  elevation: elevation,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Opacity(
                                    opacity: 0.95,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          final isCompleted = item.isCompleted;

                          return Padding(
                            key: Key(item.id),
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Dismissible(
                                key: Key('dismiss_${item.id}'),
                                direction: DismissDirection.horizontal,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 12),
                                  color: Theme.of(context).colorScheme.primary,
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 12),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    _showEditDialog(context.read<ShoppingProvider>(), item);
                                    return false;
                                  }
                                  return true;
                                },
                                onDismissed: (direction) => _deleteItem(item, context.read<ShoppingProvider>()),
                                child: GestureDetector(
                                  onTap: () => _toggleItemCompletion(item, context.read<ShoppingProvider>()),
                                  child: Stack(
                                    children: [
                                      Row(
                                    children: [
                                      Container(
                                        height: 48,
                                        width: 44,
                                        color: isCompleted
                                            ? (isDarkTheme
                                                ? Colors.white.withValues(alpha: 0.05)
                                                : Colors.black.withValues(alpha: 0.05))
                                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                                        child: Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 22,
                                            color: isCompleted
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          color: isCompleted
                                              ? (isDarkTheme
                                                  ? Colors.white.withValues(alpha: 0.05)
                                                  : Colors.black.withValues(alpha: 0.05))
                                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.quantity > 1 ? '${item.quantity}x ${item.name}' : item.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                              color: isCompleted
                                                  ? (isDarkTheme ? Colors.white54 : Colors.black38)
                                                  : Theme.of(context).colorScheme.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                      const GrainOverlay(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 48,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            const GrainOverlay(),
                            SizedBox(
                              height: 48,
                              child: TextField(
                                controller: _quickAddController,
                                decoration: InputDecoration(
                                  hintText: 'Add item...',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _quickAdd(context.read<ShoppingProvider>()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: allItems.any((i) => i.isCompleted)
                          ? () => context.read<ShoppingProvider>().clearCompleted()
                          : null,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.cleaning_services_rounded,
                                size: 20,
                                color: allItems.any((i) => i.isCompleted)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                            const GrainOverlay(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}