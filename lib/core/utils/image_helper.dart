import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageHelper {

  static Future<String?> compressToBase64(String path) async {
    try {
      final dir = await getTemporaryDirectory();

      final targetPath =
          p.join(dir.path, "cmp_${DateTime.now().millisecondsSinceEpoch}.jpg");

      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,

        quality: 65,          
        minWidth: 600,        
        minHeight: 600,
      );

      if (result == null) return null;

      final bytes = await result.readAsBytes();
      
      if (bytes.length > 800 * 1024) {
        throw Exception("Ukuran gambar terlalu besar (>800KB)");
      }

      return base64Encode(bytes);

    } catch (e) {
      throw Exception("Gagal kompres gambar: $e");
    }
  }
}
