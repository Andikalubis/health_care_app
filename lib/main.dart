import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care_app/core/theme/app_theme.dart';
import 'package:health_care_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:health_care_app/features/error/presentation/pages/not_found_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ChuckerFlutter.showOnRelease = true;
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Health',
      navigatorKey: navigatorKey,
      navigatorObservers: [ChuckerFlutter.navigatorObserver],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const NotFoundPage());
      },
    );
  }
}
