class AppConfig {
  // Android emulator -> host machine
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Real device: comment out the line above and use your laptop's LAN IP instead
  static const String baseUrl = 'http://192.168.1.13:3000/api';

  static const String apiBaseUrl = baseUrl;

  static const Duration requestTimeout = Duration(seconds: 30);

  // Fallback location used before the user picks a destination.
  static const String defaultLocationName = 'Kuala Lumpur';
  static const double defaultLatitude = 3.1390;
  static const double defaultLongitude = 101.6869;
}
