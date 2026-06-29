import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> get recordingsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<String> saveAudioFile(String sourcePath, String fileName) async {
    final dir = await recordingsDir;
    final file = File(sourcePath);
    final newPath = '$dir/$fileName';
    await file.copy(newPath);
    return newPath;
  }

  static Future<void> deleteAudioFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<List<FileSystemEntity>> listAudioFiles() async {
    final dir = await recordingsDir;
    final d = Directory(dir);
    if (!await d.exists()) return [];
    return d.listSync();
  }
}
