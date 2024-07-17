import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

/// device is iOS
bool get isIOS => !kIsWeb && Platform.isIOS;

/// device is android
bool get isAndroid => !kIsWeb && Platform.isAndroid;

/// iOS custom only functions
class IOSUtils {
  /// Unzip the zip file from WhatsApp
  static Future<bool> unzip(String zipPath, [Directory? destination]) async {
    destination ??= await getApplicationDocumentsDirectory();
    final zipFile = File(zipPath);
    try {
      debugPrint("Extracting zip file to directory: ${destination.toString()}/poddin");
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: Directory('${destination.path}/poddin'));
      return true;
    } catch (e) {
      debugPrint("Error unzipping $zipPath: $e");
      return false;
    }
  }

  /// Read the txt file inside the extracted zip file
  ///
  /// file name for ios is "_chat.txt" and "Whatsapp chat...txt" for android
  static Future<List<String>> readFile(String name, [String? path]) async {
    try {
      debugPrint('Reading zip file name: $name');
      path ??=
          '${(await getApplicationDocumentsDirectory()).path}/poddin/$name';
      debugPrint("Reading zip file path: $path");
      final file = File(path);
      List<String> lines = await file.readAsLines();
      await deleteFile(path);
      return lines;
    } catch (e) {
      debugPrint("Error reading zip file $path: $e");
      return [];
    }
  }

  /// Delete the file after we read it
  static Future<bool> deleteFile(String path) async {
    final file = File(path);
    await file.delete();
    return await file.exists();
  }
}
