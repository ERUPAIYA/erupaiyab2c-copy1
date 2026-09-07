// import 'package:e_rupaiya/services/screen_security_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'features/profile/controllers/theme_mode_controller.dart';
// import 'package:no_screenshot/no_screenshot.dart';

import 'features/profile/models/transaction_history_entry.dart';
import 'features/profile/views/transaction_detail_screen.dart';
import 'router.dart';
import 'services/app_lock_service.dart';
import 'services/in_app_update_service.dart';
import 'services/location_service.dart';
import 'services/logger_service.dart';
import 'services/navigation_interaction_lock.dart';
import 'services/push_notification_service.dart';
import 'widgets/app_snackbar.dart';

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
    
    // UI TEST MODE
    return ScreenUtilInit(
      designSize: const Size(440, 978),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const _TransactionUITestEntry(),
      ),
    );
  }
}

class _TransactionUITestEntry extends HookWidget {
  const _TransactionUITestEntry();
  @override
  Widget build(BuildContext context) {
    final statusIndex = useState(0);
    final statuses = ['PENDING', 'FAILED', 'REFUND_PENDING', 'REFUNDED', 'SUCCESS'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: TransactionDetailScreen(
              entry: TransactionHistoryEntry(
                paymentStatus: statuses[statusIndex.value],
                paymentType: 'Education',
                billerName: 'MSEDCL Maharashtra...',
                maskedIdentifier: '049338085841',
                amount: '1000.00',
                platformFees: '0',
                totalAmountCharged: '1000.00',
                customerMobile: '9876543210',
                iconUrl: '',
                pgTransactionId: '32047646601170534...',
                ecoinsTransactionId: '32047646601170534...',
                transactionId: '32047646601170534...',
                bankReferenceId: '32047646601170534...',
                referenceId: '32047646601170534...',
                transactionTime: '3 June 2026, 1:48pm',
                method: 'UPI/GPay',
                methodIcon: '',
                paymentMode: 'UPI',
                vpa: 'test@upi',
                rrn: '1234567890',
                amountBreakdown: {
                  'Recharge Amount': '₹1015',
                  'eCoins': '-₹15',
                  'Total': '₹1000',
                },
              ),
              doneLabel: 'Done',
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: Colors.black.withOpacity(0.05),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                child: Row(
                  children: List.generate(statuses.length, (index) {
                    final isSelected = statusIndex.value == index;
                    String label = statuses[index].replaceAll('_', ' ');
                    if (label == 'SUCCESS') label = 'THANK YOU';
                    
                    return GestureDetector(
                      onTap: () => statusIndex.value = index,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? (statuses[index] == 'SUCCESS' ? Colors.green : Colors.blue) 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
