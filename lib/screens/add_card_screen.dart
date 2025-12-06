import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';
import '../utils/barcode_utils.dart';
import 'barcode_scanner_screen.dart';

class AddCardScreen extends StatefulWidget {
  final Map<String, dynamic>? editCard;
  
  const AddCardScreen({super.key, this.editCard});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  String barcodeFormat = 'code128';
  String selectedCategory = 'Other';
  bool isFavorite = false;
  String selectedColor = '#0066CC';
  bool get isEditMode => widget.editCard != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.editCard!['shopName'] ?? '';
      descriptionController.text = widget.editCard!['description'] ?? '';
      numberController.text = widget.editCard!['cardNumber'] ?? '';
      barcodeFormat = widget.editCard!['barcodeFormat'] ?? 'code128';
      selectedCategory = widget.editCard!['category'] ?? 'Other';
      isFavorite = widget.editCard!['isFavorite'] ?? false;
      selectedColor = widget.editCard!['color'] ?? '#0066CC';
    }
  }

  void _startScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        numberController.text = result['code'] ?? '';
        barcodeFormat = result['format'] ?? 'code128';
      });
    }
  }

  void _saveCard() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a shop name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a card number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'name': nameController.text,
      'description': descriptionController.text,
      'code': numberController.text,
      'barcodeFormat': barcodeFormat,
      'category': selectedCategory,
      'isFavorite': isFavorite,
      'color': selectedColor,
    });
  }

  @override
  Widget build(BuildContext context) {
    final String code = numberController.text;
    final String? svgCode = code.isNotEmpty ? BarcodeUtils.generate(code, barcodeFormat) : null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          isEditMode ? "Edit card" : "Add card",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Shop name",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Description (optional)",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: numberController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Card number",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: _startScan,
                ),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: AppConstants.cardCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        AppConstants.categoryIcons[category],
                        color: AppConstants.categoryColors[category],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Icon(
                  Icons.star,
                  color: isFavorite ? Colors.amber : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mark as favorite',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: isFavorite,
                  onChanged: (value) {
                    setState(() {
                      isFavorite = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Color',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppConstants.cardBackgroundColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorUtils.hexToColor(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 30),

            if (svgCode != null)
              Column(
                children: [
                  SvgPicture.string(svgCode, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)),
                  const SizedBox(height: 30),
                ],
              ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _saveCard,
              child: Text(isEditMode ? "Update" : "Save"),
            ),
            const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
