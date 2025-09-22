import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String paypalClientId;
  static late String paypalSecret;

  static void init() {
    paypalClientId = dotenv.env['PAYPAL_CLIENT_ID'] ?? '';
    paypalSecret = dotenv.env['PAYPAL_SECRET'] ?? '';
  }
}
