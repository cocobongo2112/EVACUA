import 'package:flutter/material.dart';

import '../screens/emergency/emergency_screen.dart';
import '../screens/equipment/emergency_equipment_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/qr/qr_scanner_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/route/evacuation_route_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/zone/my_zone_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String qrScanner = '/qr';
  static const String myZone = '/zone';
  static const String evacuationRoute = '/route';
  static const String emergency = '/emergency';
  static const String equipment = '/equipment';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        qrScanner: (_) => const QrScannerScreen(),
        myZone: (_) => const MyZoneScreen(),
        evacuationRoute: (_) => const EvacuationRouteScreen(),
        emergency: (_) => const EmergencyScreen(),
        equipment: (_) => const EmergencyEquipmentScreen(),
      };
}
