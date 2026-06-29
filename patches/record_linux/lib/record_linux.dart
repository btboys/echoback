import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:record_platform_interface/record_platform_interface.dart';

class RecordLinuxPlugin {
  static void registerWith() {}
}

class RecordLinux extends RecordPlatform {
  @override
  Future<void> create(String recorderId) async {}

  @override
  Future<void> start(String recorderId, RecordConfig config, {required String path}) async {}

  @override
  Future<Stream<Uint8List>> startStream(String recorderId, RecordConfig config) async =>
      const Stream.empty();

  @override
  Future<String?> stop(String recorderId) async => null;

  @override
  Future<void> pause(String recorderId) async {}

  @override
  Future<void> resume(String recorderId) async {}

  @override
  Future<bool> isRecording(String recorderId) async => false;

  @override
  Future<bool> isPaused(String recorderId) async => false;

  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async => false;

  @override
  Future<bool> isEncoderSupported(String recorderId, AudioEncoder encoder) async => false;

  @override
  Future<Amplitude> getAmplitude(String recorderId) async => Amplitude(current: 0, max: 0);

  @override
  Future<void> cancel(String recorderId) async {}

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  Stream<RecordState> onStateChanged(String recorderId) => const Stream.empty();

  @override
  Future<List<InputDevice>> listInputDevices(String recorderId) async => [];
}
