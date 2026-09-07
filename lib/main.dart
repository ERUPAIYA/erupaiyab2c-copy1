// import 'package:e_rupaiya/services/screen_security_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'features/profile/controllers/theme_mode_controller.dart';
// import 'package:no_screenshot/no_screenshot.dart';

import 'router.dart';
import 'services/app_lock_service.dart';
import 'services/in_app_update_service.dart';
import 'services/location_service.dart';
import 'services/logger_service.dart';
import 'services/navigation_interaction_lock.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // NoScreenshot.instance.screenshotOff();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  Future.microtask(() async {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }
    } catch (e, stackTrace) {
      logger.error('Failed to load .env', error: e, stackTrace: stackTrace);
    }
    try {
      await PushNotificationService.initialize(requestPermissions: false);
    } catch (e, stackTrace) {
      logger.error(
        'Push notification initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
    try {
      await LocationService.initialize(requestPermission: false);
    } catch (e, stackTrace) {
      logger.error(
        'Location service initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  });
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final appLockService = ref.read(appLockServiceProvider);
    final navigationInteractionLock =
        ref.watch(navigationInteractionLockProvider);
    useListenable(navigationInteractionLock);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
      return null;
    }, const []);
    useEffect(() {
      Future.microtask(() {
        InAppUpdateService.checkForImmediateUpdate();
      });
      return null;
    }, const []);
    useEffect(() {
      appLockService.init();
      // ScreenSecurityService.enableSecure();
      return appLockService.dispose;
    }, const []);
    useEffect(() {
      // Allows PushNotificationService to navigate after notification taps.
      PushNotificationService.markUiReady();
      return null;
    }, const []);

    return ScreenUtilInit(
      designSize: const Size(440, 978),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(
          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
          scaffoldBackgroundColor: Colors.white,
        ),
        routerConfig: router,
      ),
    );
  }
}
