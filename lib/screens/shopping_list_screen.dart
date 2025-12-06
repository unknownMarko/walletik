import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../widgets/background_logo.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';
import '../utils/constants.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
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

  Future<void> _showAddEditDialog(ShoppingProvider provider, [ShoppingItem? existingItem]) async {
    final isEditing = existingItem != null;
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final quantityController = TextEditingController(
      text: existingItem?.quantity.toString() ?? '1'
    );
    final notesController = TextEditingController(text: existingItem?.notes ?? '');
    String selectedCategory = existingItem?.category ?? 'Groceries';

    final result = await showDialog<ShoppingItem>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Item' : 'Add Item'),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: AppConstants.shoppingCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Additional details...',
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

                    final newItem = ShoppingItem(
                      id: existingItem?.id ?? '',
                      name: nameController.text.trim(),
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      category: selectedCategory,
                      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      isCompleted: existingItem?.isCompleted ?? false,
                      createdAt: existingItem?.createdAt ?? DateTime.now(),
                    );
                    Navigator.pop(context, newItem);
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      if (isEditing) {
        await provider.updateItem(existingItem, result);
      } else {
        await provider.addItem(result);
      }
    }
  }

  Widget _buildCategoryIcon(String category) {
    final icon = AppConstants.shoppingCategoryIcons[category] ?? Icons.category;
    final color = AppConstants.shoppingCategoryColors[category] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = context.watch<ShoppingProvider>();
    final allItems = shoppingProvider.items;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final completedItems = shoppingProvider.completedItems;
    final pendingItems = shoppingProvider.pendingItems;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BackgroundLogo(
        child: SafeArea(
          child: Column(
            children: [
              if (allItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${pendingItems.length} pending, ${completedItems.length} completed',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      Visibility(
                        visible: completedItems.isNotEmpty,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: InkWell(
                          onTap: () => shoppingProvider.clearCompleted(),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              'Clear completed',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                              'Tap + to add your first item',
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
                        onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, shoppingProvider),
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
                            onDismissed: (direction) => _deleteItem(item, shoppingProvider),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: isCompleted
                                  ? (isDarkTheme
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.05))
                                  : (isDarkTheme
                                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                                      : Colors.white),
                              child: ListTile(
                                leading: _buildCategoryIcon(item.category),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? (isDarkTheme ? Colors.white54 : Colors.black38)
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.quantity != 1)
                                      Text(
                                        'Quantity: ${item.quantity}',
                                        style: TextStyle(
                                          color: isCompleted
                                              ? (isDarkTheme ? Colors.white38 : Colors.black26)
                                              : null,
                                        ),
                                      ),
                                    if (item.notes != null && item.notes!.isNotEmpty)
                                      Text(
                                        item.notes!,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: isCompleted
                                              ? (isDarkTheme ? Colors.white38 : Colors.black26)
                                              : null,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _showAddEditDialog(shoppingProvider, item),
                                    ),
                                    Checkbox(
                                      value: isCompleted,
                                      onChanged: (_) => _toggleItemCompletion(item, shoppingProvider),
                                      activeColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                                onTap: () => _showAddEditDialog(shoppingProvider, item),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(shoppingProvider),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}