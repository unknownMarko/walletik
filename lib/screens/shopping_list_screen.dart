import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';
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
  int _quickAddQuantity = 1;

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
      quantity: _quickAddQuantity,
      category: 'Groceries',
      createdAt: DateTime.now(),
    );
    await provider.addItem(item);
    _quickAddController.clear();
    setState(() => _quickAddQuantity = 1);
  }

  Future<void> _showEditDialog(ShoppingProvider provider, ShoppingItem item) async {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());

    final result = await showDialog<ShoppingItem>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g., Milk, Bread',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: '1',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
                Navigator.pop(context, updated);
              },
              child: const Text('Save'),
            ),
          ],
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

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _quickAddController,
                          decoration: InputDecoration(
                            hintText: 'Add item...',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _quickAddQuantity = _quickAddQuantity >= 9 ? 1 : _quickAddQuantity + 1;
                                });
                              },
                              child: Container(
                                width: 36,
                                alignment: Alignment.center,
                                child: Text(
                                  '${_quickAddQuantity}x',
                                  style: TextStyle(
                                    color: _quickAddQuantity > 1
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _quickAdd(context.read<ShoppingProvider>()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _quickAdd(context.read<ShoppingProvider>()),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                              final double elevation = lerpDouble(0, 8, animValue)!;
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

                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) => _deleteItem(item, context.read<ShoppingProvider>()),
                            child: GestureDetector(
                              onTap: () => _toggleItemCompletion(item, context.read<ShoppingProvider>()),
                              onLongPress: () => _showEditDialog(context.read<ShoppingProvider>(), item),
                              child: Container(
                                height: 48,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? (isDarkTheme
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.05))
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
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
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: isCompleted,
                                        onChanged: (_) => _toggleItemCompletion(item, context.read<ShoppingProvider>()),
                                        activeColor: Theme.of(context).colorScheme.primary,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
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
}