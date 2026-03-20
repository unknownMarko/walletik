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
  String selectedColor = '#0066CC';
  bool get isEditMode => widget.editCard != null;

  @override
  void initState() {
    super.initState();
    numberController.addListener(() => setState(() {}));
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

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final code = numberController.text;
    final svgCode = code.isNotEmpty ? BarcodeUtils.generate(code, barcodeFormat) : null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          isEditMode ? "Edit card" : "Add card",
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Column(
                    children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _inputDecoration("Shop name"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _inputDecoration("Description (optional)"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: numberController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _inputDecoration(
                      "Card number",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code_scanner, color: colorScheme.onSurfaceVariant),
                        onPressed: _startScan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Color',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppConstants.cardBackgroundColors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
                            child: Container(
                              width: 38,
                              height: 38,
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
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (svgCode != null) ...[
                    SvgPicture.string(
                      svgCode,
                      colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn),
                    ),
                  ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveCard,
                      child: Text(
                        isEditMode ? "Update" : "Save",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
