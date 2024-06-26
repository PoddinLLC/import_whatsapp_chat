import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

/// iOS custom only functions
class IOSUtils {
  /// Unzip the zip file from WhatsApp
  static Future<bool> unzip(String zipPath, [Directory? destination]) async {
    destination ??= await getApplicationSupportDirectory();
    final zipFile = File(zipPath);
    try {
      debugPrint("Extracting zip file to directory: ${destination.toString()}");
      await ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: destination);
      return true;
    } catch (e) {
      debugPrint("Error unzipping $zipPath: $e");
      return false;
    }
  }

  /// Read the txt file inside the extracted zip file
  static Future<List<String>> readFile([String? path]) async {
    try {
      path ??= '${(await getApplicationSupportDirectory()).path}/_chat.txt';
      debugPrint("Reading zip file: $path");
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
