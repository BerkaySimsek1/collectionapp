import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get projectId => dotenv.env['PROJECT_ID'] ?? '';
  static String get messagingSenderId =>
      dotenv.env['MESSAGING_SENDER_ID'] ?? '';
  static String get authDomain => dotenv.env['AUTH_DOMAIN'] ?? '';
  static String get storageBucket => dotenv.env['STORAGE_BUCKET'] ?? '';

  static String get webApiKey => dotenv.env['WEB_API_KEY'] ?? '';
  static String get webAppId => dotenv.env['WEB_APP_ID'] ?? '';
  static String get measurementId => dotenv.env['MEASUREMENT_ID'] ?? '';

  static String get androidApiKey => dotenv.env['ANDROID_API_KEY'] ?? '';
  static String get androidAppId => dotenv.env['ANDROID_APP_ID'] ?? '';

  static String get iosApiKey => dotenv.env['IOS_API_KEY'] ?? '';
  static String get iosAppId => dotenv.env['IOS_APP_ID'] ?? '';
  static String get iosBundleId => dotenv.env['IOS_BUNDLE_ID'] ?? '';

  static String get windowsApiKey => dotenv.env['WINDOWS_API_KEY'] ?? '';
  static String get windowsAppId => dotenv.env['WINDOWS_APP_ID'] ?? '';
  static String get windowsBundleId => dotenv.env['WINDOWS_BUNDLE_ID'] ?? '';

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("Environment variables loaded successfully");
    } catch (e) {
      debugPrint("Error loading .env file: $e");
    }
  }
}
