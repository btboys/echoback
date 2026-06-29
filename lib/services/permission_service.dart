import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class PermissionService {
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> hasMicrophonePermission() async {
    try {
      return await Permission.microphone.isGranted;
    } on MissingPluginException {
      return true;
    }
  }
}
