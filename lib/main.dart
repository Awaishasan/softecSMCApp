import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:softec_sme_app/res/Routes/appRoute.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.SPLASH,
      getPages: pageRoute.pages,
      themeMode: ThemeMode.light, // GetX will override this via Get.changeThemeMode()
      theme: _lightTheme,
      darkTheme: _darkTheme,
    );
  }
}

// ── Light theme ────────────────────────────────────────────────────────────────
final _lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0A375C),
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF0A375C),
    elevation: 0,
  ),
  cardColor: Colors.white,
  dividerColor: Color(0xFFE0E0E0),
);

// ── Dark theme ─────────────────────────────────────────────────────────────────
final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4A90D9),
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1A1A2E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0xFF2C2C2C),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A1A2E),
    selectedItemColor: Color(0xFF4A90D9),
    unselectedItemColor: Colors.grey,
  ),
);
