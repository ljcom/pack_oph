import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessor {
  static Future<String> cropImg(String srcFilePath,
      {bool flip, double ratioWH: 1}) async {
    String destFilePath = srcFilePath.split('/').last;
    destFilePath = destFilePath.split('.').join('_cropped.');
    final appDir = await syspaths.getTemporaryDirectory();
    destFilePath = appDir.path + '/' + destFilePath;

    var bytes = await File(srcFilePath).readAsBytes();
    if (bytes.length > 0) {
      IMG.Image src = IMG.decodeImage(bytes);

      int cropWidth = min(src.width, (src.height * ratioWH).toInt());
      int cropHeight = src.width ~/ 2;
      int offsetX = (src.width - cropWidth) ~/ 2;
      int offsetY = ((src.height - cropHeight) ~/ 2).toInt();

      IMG.Image destImage =
          IMG.copyCrop(src, offsetX, offsetY, cropWidth, cropHeight);

      if (flip) {
        destImage = IMG.flipVertical(destImage);
      }

      var jpg = IMG.encodeJpg(destImage);
      var jpgCompress = await FlutterImageCompress.compressWithList(
        jpg,
        minHeight: 1920,
        minWidth: 1080,
        quality: 96,
        rotate: 0,
      );
      await File(destFilePath).writeAsBytes(jpgCompress);
    }
    return destFilePath;
  }
}
