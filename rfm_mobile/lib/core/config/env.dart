import 'package:flutter/foundation.dart';

class Env {
  static const String _devBaseUrl = 'http://192.168.1.34:3000/api';
  static const String _prodBaseUrl = 'https://rfm-five.vercel.app/api';

  static String get baseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;
}
