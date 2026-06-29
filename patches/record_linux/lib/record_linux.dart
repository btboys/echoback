import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:record_platform_interface/record_platform_interface.dart';

class RecordLinuxPlugin {
  static void registerWith() {}
}

class RecordLinux extends RecordPlatform {
  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async => false;

  @override
  Future<String?> start(String recorderId, RecordConfig config, String path) async => null;

  @override
  Future<Stream<Uint8List>> startStream(String recorderId, RecordConfig config) async =>
      const Stream.empty();

  @override
  Future<void> stop(String recorderId) async {}

  @override
  Future<void> cancel(String recorderId) async {}

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  Future<void> pause(String recorderId) async {}

  @override
  Future<void> resume(String recorderId) async {}

  @override
  Future<bool> isEncoderSupported(RecordConfig config) async => false;

  @override
  Future<bool> isPauseSupported(String recorderId) async => false;

  @override
  Future<Amplitude?> getAmplitude(String recorderId) async => null;

  @override
  Future<RecordState> getState(String recorderId) async => RecordState.stop;

  @override
  Future<void> setLogLevel(LogLevel? level) async {}
}
