import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:barcode/barcode.dart' as bc;
import 'package:flutter_svg/flutter_svg.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  Color selectedColor = Colors.blue;

  void _startScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );

    if (result != null && result is String) {
      setState(() => numberController.text = result);
    }
  }

  void _saveCard() {
    if (nameController.text.isNotEmpty && numberController.text.isNotEmpty) {
      Navigator.pop(context, {
        'name': nameController.text,
        'description': descriptionController.text,
        'code': numberController.text,
        'color': selectedColor.value, 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String code = numberController.text;

    String? svgCode;
    if (code.isNotEmpty) {
      final barcode = bc.Barcode.code128();
      svgCode = barcode.toSvg(
        code,
        width: 300,
        height: 100,
        drawText: false,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Add card",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop name
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Shop name",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card number
              TextField(
                controller: numberController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Card number",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: _startScan,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Generated barcode
              if (svgCode != null)
                Column(
                  children: [
                    SvgPicture.string(
                      svgCode,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),

              // Palette
              const Text(
                "Choose card color:",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                  Colors.teal,
                  Colors.grey,
                ].map((color) {
                  final bool isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Save button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1b2345),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _saveCard,
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_hasDetected) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final String? rawValue = barcodes.first.rawValue;
          if (rawValue != null) {
            _hasDetected = true;
            Navigator.pop(context, rawValue);
          }
        },
      ),
    );
  }
}
