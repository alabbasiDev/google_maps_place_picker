import 'dart:io';

import 'package:flutter/foundation.dart';

class APIKeys {
  static String get apiKey {
    if (kIsWeb) {
      return 'web_api_key_goes_here';
    }
    if(Platform.isAndroid){
      return 'android_api_key_goes_here';
    }

    return 'ios_api_key_goes_here';
  }
}
