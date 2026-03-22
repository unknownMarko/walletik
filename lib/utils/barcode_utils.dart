import 'package:barcode/barcode.dart';

class BarcodeUtils {
  static String generate(String data, String format) {
    Barcode barcode;
    switch (format) {
      case 'qrCode':
        barcode = Barcode.qrCode();
        break;
      case 'ean13':
        barcode = Barcode.ean13();
        break;
      case 'code39':
        barcode = Barcode.code39();
        break;
      case 'pdf417':
        barcode = Barcode.pdf417();
        break;
      case 'ean8':
        barcode = Barcode.ean8();
        break;
      case 'dataMatrix':
        barcode = Barcode.dataMatrix();
        break;
      default:
        barcode = Barcode.code128();
    }

    try {
      return barcode.toSvg(
        data,
        width: format == 'qrCode' ? 200 : 280,
        height: format == 'qrCode' ? 200 : 80,
        drawText: false,
      );
    } catch (e) {
      final fallbackBarcode = Barcode.code128();
      return fallbackBarcode.toSvg(data, width: 280, height: 80, drawText: false);
    }
  }
}
