import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeMediaController {
  static const MethodChannel _channel = MethodChannel('com.example.fitza/media_control');

  static Future<void> playPause() async {
    try {
      await _channel.invokeMethod('play_pause');
    } on PlatformException catch (e) {
      debugPrint("Failed to send play_pause: '${e.message}'.");
    }
  }

  static Future<void> next() async {
    try {
      await _channel.invokeMethod('next');
    } on PlatformException catch (e) {
      debugPrint("Failed to send next: '${e.message}'.");
    }
  }

  static Future<void> previous() async {
    try {
      await _channel.invokeMethod('previous');
    } on PlatformException catch (e) {
      debugPrint("Failed to send previous: '${e.message}'.");
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException catch (e) {
      debugPrint("Failed to send stop: '${e.message}'.");
    }
  }

  static Future<bool> isMusicActive() async {
    try {
      final bool? isActive = await _channel.invokeMethod<bool>('is_music_active');
      return isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to check is_music_active: '${e.message}'.");
      return false;
    }
  }

  static Future<Map<String, dynamic>> getExtractedMediaInfo() async {
    try {
      final Map<dynamic, dynamic>? res = await _channel.invokeMethod<Map<dynamic, dynamic>>('get_extracted_media_info');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get_extracted_media_info: '${e.message}'.");
    }
    return {"is_active": false, "source": "None"};
  }
}



