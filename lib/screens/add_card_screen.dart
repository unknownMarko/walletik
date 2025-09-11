import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:barcode/barcode.dart' as bc;
import 'package:flutter_svg/flutter_svg.dart';

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
  bool get isEditMode => widget.editCard != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.editCard!['shopName'] ?? '';
      descriptionController.text = widget.editCard!['description'] ?? '';
      numberController.text = widget.editCard!['cardNumber'] ?? '';
      barcodeFormat = widget.editCard!['barcodeFormat'] ?? 'code128';
    }
  }

  void _startScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        numberController.text = result['value'] ?? '';
        barcodeFormat = result['format'] ?? 'code128';
      });
    }
  }

  void _saveCard() {
    if (nameController.text.isNotEmpty && numberController.text.isNotEmpty) {
      Navigator.pop(context, {
        'name': nameController.text,
        'description': descriptionController.text,
        'code': numberController.text,
        'barcodeFormat': barcodeFormat,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String code = numberController.text;

    String? svgCode;
    if (code.isNotEmpty) {
      bc.Barcode barcode;
      switch (barcodeFormat) {
        case 'qrCode':
          barcode = bc.Barcode.qrCode();
          break;
        case 'ean13':
          barcode = bc.Barcode.ean13();
          break;
        case 'code39':
          barcode = bc.Barcode.code39();
          break;
        case 'pdf417':
          barcode = bc.Barcode.pdf417();
          break;
        case 'ean8':
          barcode = bc.Barcode.ean8();
          break;
        case 'dataMatrix':
          barcode = bc.Barcode.dataMatrix();
          break;
        default:
          barcode = bc.Barcode.code128();
      }
      
      try {
        svgCode = barcode.toSvg(
          code,
          width: barcodeFormat == 'qrCode' ? 200 : 300,
          height: barcodeFormat == 'qrCode' ? 200 : 100,
          drawText: false,
        );
      } catch (e) {
        // Fallback to code128 if format fails
        barcode = bc.Barcode.code128();
        svgCode = barcode.toSvg(
          code,
          width: 300,
          height: 100,
          drawText: false,
        );
        barcodeFormat = 'code128';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          isEditMode ? "Edit card" : "Add card",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Shop name
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

            // Description
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

            // Card number
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
            const SizedBox(height: 30),

            // Generated barcode
            if (svgCode != null)
              Column(
                children: [
                  SvgPicture.string(svgCode, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)),
                  const SizedBox(height: 30),
                ],
              ),

            // Save button
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
          ],
        ),
      ),
    );
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _hasDetected = false;
  
  String _formatToString(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'qrCode';
      case BarcodeFormat.ean13:
        return 'ean13';
      case BarcodeFormat.code39:
        return 'code39';
      case BarcodeFormat.pdf417:
        return 'pdf417';
      case BarcodeFormat.ean8:
        return 'ean8';
      case BarcodeFormat.upcA:
        return 'upca';
      case BarcodeFormat.upcE:
        return 'upce';
      case BarcodeFormat.itf:
        return 'itf';
      case BarcodeFormat.dataMatrix:
        return 'dataMatrix';
      case BarcodeFormat.aztec:
        return 'aztec';
      default:
        return 'code128';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_hasDetected) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;
          
          final barcode = barcodes.first;
          final String? rawValue = barcode.rawValue;
          if (rawValue != null) {
            _hasDetected = true;
            Navigator.pop(context, {
              'value': rawValue,
              'format': _formatToString(barcode.format),
            });
          }
        },
      ),
    );
  }
}
