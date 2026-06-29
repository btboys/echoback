import 'package:flutter/foundation.dart';
import '../models/recording.dart';
import '../services/recording_service.dart';
import '../services/storage_service.dart';

class RecordingProvider extends ChangeNotifier {
  final RecordingService _service = RecordingService();

  List<Recording> _recordings = [];

  List<Recording> get recordings => _recordings;

  Future<void> loadRecordings() async {
    _recordings = await _service.getAll();
    notifyListeners();
  }

  Future<int> addRecording(Recording recording) async {
    final id = await _service.insert(recording);
    await loadRecordings();
    return id;
  }

  Future<void> deleteRecording(Recording recording) async {
    if (recording.id != null) {
      await _service.delete(recording.id!);
    }
    await StorageService.deleteAudioFile(recording.filePath);
    await loadRecordings();
  }

  Future<void> renameRecording(Recording recording, String newName) async {
    final updated = recording.copyWith(
      fileName: newName,
    );
    if (recording.id != null) {
      await _service.update(updated);
    }
    await loadRecordings();
  }

  Future<void> deleteMultiple(List<Recording> items) async {
    for (final r in items) {
      if (r.id != null) {
        await _service.delete(r.id!);
      }
      await StorageService.deleteAudioFile(r.filePath);
    }
    await loadRecordings();
  }
}
