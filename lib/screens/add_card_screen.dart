import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/color_utils.dart';
import 'barcode_scanner_screen.dart';

class AddCardScreen extends StatefulWidget {
  final Map<String, dynamic>? editCard;
  
  const AddCardScreen({super.key, this.editCard});

  /// Show as bottom sheet. Returns card data map or null.
  static Future<Map<String, dynamic>?> show(BuildContext context, {Map<String, dynamic>? editCard}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      builder: (_) => AddCardScreen(editCard: editCard),
    );
  }

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  String barcodeFormat = 'code128';
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
      selectedColor = widget.editCard!['color'] ?? '#0066CC';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    numberController.dispose();
    super.dispose();
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
        SnackBar(
          content: const Text('Please enter a shop name'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a card number'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'name': nameController.text,
      'description': descriptionController.text,
      'code': numberController.text,
      'barcodeFormat': barcodeFormat,
      'color': selectedColor,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
            isEditMode ? 'Edit Card' : 'Add Card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Shop name',
              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: numberController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Card number',
              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_scanner, color: colorScheme.onSurfaceVariant),
                onPressed: _startScan,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Card Color',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.7, 0.85, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.cardBackgroundColors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final color = AppConstants.cardBackgroundColors[index];
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ColorUtils.hexToColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saveCard,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditMode ? 'Update' : 'Save',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
