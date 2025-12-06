import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/background_logo.dart';
import '../services/shopping_list_storage.dart';
import '../models/shopping_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> allItems = [];
  
  final List<String> categories = [
    'Groceries',
    'Electronics',
    'Clothing',
    'Home',
    'Health',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await ShoppingListStorage.loadItems();
    setState(() {
      allItems = items;
    });
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = allItems.removeAt(oldIndex);
      allItems.insert(newIndex, item);
    });
    
    await ShoppingListStorage.saveItems(allItems);
  }


  Future<void> _toggleItemCompletion(ShoppingItem item) async {
    await ShoppingListStorage.toggleItemCompletion(item);
    await _loadItems();
  }

  Future<void> _deleteItem(ShoppingItem item) async {
    await ShoppingListStorage.removeItem(item);
    await _loadItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await ShoppingListStorage.addItem(item);
              await _loadItems();
            },
          ),
        ),
      );
    }
  }

  Future<void> _showAddEditDialog([ShoppingItem? existingItem]) async {
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
                      items: categories.map((category) {
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
        await ShoppingListStorage.updateItem(existingItem, result);
      } else {
        await ShoppingListStorage.addItem(result);
      }
      await _loadItems();
    }
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;
    
    switch (category) {
      case 'Groceries':
        icon = Icons.shopping_basket;
        color = Colors.green;
        break;
      case 'Electronics':
        icon = Icons.devices;
        color = Colors.blue;
        break;
      case 'Clothing':
        icon = Icons.checkroom;
        color = Colors.purple;
        break;
      case 'Home':
        icon = Icons.home;
        color = Colors.orange;
        break;
      case 'Health':
        icon = Icons.medical_services;
        color = Colors.red;
        break;
      default:
        icon = Icons.category;
        color = Colors.grey;
    }
    
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final completedItems = allItems.where((item) => item.isCompleted).toList();
    final pendingItems = allItems.where((item) => !item.isCompleted).toList();

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
                          onTap: () async {
                            await ShoppingListStorage.clearCompleted();
                            await _loadItems();
                          },
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
                        onReorder: _onReorder,
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
                            onDismissed: (direction) => _deleteItem(item),
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
                                      onPressed: () => _showAddEditDialog(item),
                                    ),
                                    Checkbox(
                                      value: isCompleted,
                                      onChanged: (_) => _toggleItemCompletion(item),
                                      activeColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                                onTap: () => _showAddEditDialog(item),
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
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}