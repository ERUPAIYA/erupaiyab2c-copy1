// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:e_rupaiya/constants/app_text_styles.dart';
import 'package:e_rupaiya/features/home/components/home_shimmer.dart';
import 'package:e_rupaiya/features/home/models/banner_model.dart';
import 'package:e_rupaiya/features/spinandear/views/spin_and_win_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../config/temporary_block_debug_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../services/location_access_service.dart';
import '../../../services/location_service.dart';
import '../../../services/notification_badge_service.dart';
import '../../../services/push_notification_service.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/complete_profile_dialog.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../../auth/components/temporary_block_dialog.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/otp_verification_args.dart';
import '../../connectivity/controllers/connectivity_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/models/profile_model.dart';
import '../../profile/views/offers_view.dart';
import '../../profile/views/profile_view.dart';
import '../../profile/views/transaction_history_screen.dart';
import '../../refer_and_earn/views/refer_and_earn_view.dart';
import '../../services/controllers/biller_detail_controller.dart';
import '../../services/models/biller_detail_args.dart';
import '../../services/models/biller_model.dart';
import '../../spinandear/controllers/spin_options_controller.dart';
import '../components/exit_app_dialog.dart';
import '../components/home_icon_tile.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_tab_controller.dart';
import '../models/bill_reminder_model.dart';
import '../models/quick_action_model.dart';
import '../repositories/home_repository.dart';
import '../utils/banner_redirect_mapper.dart';
import 'home_search_view.dart';
import 'notifications_screen.dart';

part 'home_view_parts.dart';

void _showInvestmentComingSoonMessage() {
  AppSnackbar.show(
    'This service is currently unavailable. Sorry for the inconvenience.',
  );
}

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(homeTabControllerProvider);
    final lastTabIndex = useRef<int>(tabController.index);
    final lastNonSpinTabIndex = useRef<int>(tabController.index);
    final isExitDialogOpen = useRef<bool>(false);
    final didRequestPermissions = useRef<bool>(false);
    final tabs = [
      const _HomeContent(),
      const OffersView(),
      const SizedBox.shrink(),
      const NotificationsScreen(),
      const TransactionHistoryScreen(),
    ];

    final navItems = [
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: _HomeNavTabItem(
          asset: FileConstants.paybillActive,
          label: 'Pay Bills',
          isActive: true,
        ),
        inactiveIcon: _HomeNavTabItem(
          asset: FileConstants.paybillInactive,
          label: 'Pay Bills',
          isActive: false,
        ),
        title: null,
        activeColorPrimary: const Color(0xFF000000),
        inactiveColorPrimary: const Color(0xFF6D6D6D),
      ),
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: _HomeNavTabItem(
          asset: FileConstants.offersActive,
          label: 'Offers',
          isActive: true,
        ),
        inactiveIcon: _HomeNavTabItem(
          asset: FileConstants.offersInactive,
          label: 'Offers',
          isActive: false,
        ),
        title: null,
        activeColorPrimary: const Color(0xFF000000),
        inactiveColorPrimary: const Color(0xFF6D6D6D),
      ),
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: _GradientFabIcon(
          asset: FileConstants.spinBottom,
          iconColor: Colors.white,
        ),
        inactiveIcon: _GradientFabIcon(
          asset: FileConstants.spinBottom,
          iconColor: Colors.white,
        ),
        title: null,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.primary,
      ),
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: _HomeNavTabItem(
          asset: FileConstants.alertsActive,
          label: 'Alerts',
          isActive: true,
          showBadge: true,
        ),
        inactiveIcon: _HomeNavTabItem(
          asset: FileConstants.alertsInactive,
          label: 'Alerts',
          isActive: false,
          showBadge: true,
        ),
        title: null,
        activeColorPrimary: const Color(0xFF000000),
        inactiveColorPrimary: const Color(0xFF6D6D6D),
      ),
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: _HomeNavTabItem(
          asset: FileConstants.historyActive,
          label: 'History',
          isActive: true,
        ),
        inactiveIcon: _HomeNavTabItem(
          asset: FileConstants.historyInactive,
          label: 'History',
          isActive: false,
        ),
        title: null,
        activeColorPrimary: const Color(0xFF000000),
        inactiveColorPrimary: const Color(0xFF6D6D6D),
      ),
    ];

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final assets = <String>[
          FileConstants.paybillActive,
          FileConstants.paybillInactive,
          FileConstants.offersActive,
          FileConstants.offersInactive,
          FileConstants.spinBottom,
          FileConstants.alertsActive,
          FileConstants.alertsInactive,
          FileConstants.historyActive,
          FileConstants.historyInactive,
          FileConstants.referandearn,
          FileConstants.coinOuter,
          FileConstants.coinInner,
          FileConstants.bharatConnectColor,
        ];
        for (final asset in assets) {
          precacheImage(AssetImage(asset), context);
        }
      });
      return null;
    }, const []);

    useEffect(() {
      NotificationBadgeService.refreshCount();
      Future.microtask(() {
        // Update device token only after user is logged in and Home is open.
        PushNotificationService.syncTokenToServerIfLoggedIn();
      });
      void listener() {
        final index = tabController.index;
        if (index == 0 && lastTabIndex.value != 0) {
          ref
              .read(profileControllerProvider.notifier)
              .fetchProfileIfNeeded(ttl: const Duration(seconds: 30));
        }
        if (index != 2) {
          lastNonSpinTabIndex.value = index;
        }
        lastTabIndex.value = index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    useEffect(() {
      if (didRequestPermissions.value) return null;
      didRequestPermissions.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.microtask(() async {
          await PushNotificationService.ensurePermissionsRequested();
          final enabled = await LocationAccessService.isEnabledPreference();
          await LocationService.initialize(requestPermission: enabled);
        });
      });
      return null;
    }, const []);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFF835C),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false,
        ),
      );
      return null;
    }, const []);

    Future<void> showExitDialog() async {
      if (isExitDialogOpen.value) return;
      isExitDialogOpen.value = true;
      try {
        await KDialog.instance.openDialog(
          barrierDismissible: false,
          dialog: ExitAppDialog(
            onConfirm: () => SystemNavigator.pop(),
          ),
        );
      } finally {
        isExitDialogOpen.value = false;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (tabController.index != 0) {
          tabController.jumpToTab(0);
          return;
        }
        showExitDialog();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFF835C),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false,
        ),
        child: PersistentTabView(
        context,
        controller: tabController,
        screens: tabs,
        items: navItems,
        navBarStyle: NavBarStyle.simple,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0),
          colorBehindNavBar: Colors.white,
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, -7),
              blurRadius: 14,
              color: Color(0x1ABFBFBF),
            ),
            BoxShadow(
              offset: Offset(0, -26),
              blurRadius: 26,
              color: Color(0x17BFBFBF),
            ),
            BoxShadow(
              offset: Offset(0, -59),
              blurRadius: 35,
              color: Color(0x0DBFBFBF),
            ),
            BoxShadow(
              offset: Offset(0, -104),
              blurRadius: 42,
              color: Color(0x03BFBFBF),
            ),
            BoxShadow(
              offset: Offset(0, -163),
              blurRadius: 46,
              color: Color(0x00BFBFBF),
            ),
          ],
        ),
        navBarHeight: 70.h,
        padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
        backgroundColor: Colors.white,
        hideNavigationBarWhenKeyboardAppears: true,
        confineToSafeArea: true,
        onItemSelected: (index) {
          // Only keep bottom bar for: Home, Offers, Alerts, History.
          // Spin & Win should open as a full screen (no bottom bar).
          if (index == 2) {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const SpinAndWinView(),
              withNavBar: false,
            );
            // Immediately restore the previous tab selection.
            tabController.jumpToTab(lastNonSpinTabIndex.value);
            return;
          }
        },
      ),
      ),
    );

    // return PersistentTabView(
    //   context,
    //   screens: tabs,
    //   items: navItems,
    //   navBarStyle: NavBarStyle.style15,
    //   decoration: NavBarDecoration(
    //     borderRadius: BorderRadius.circular(0),
    //     gradient: const LinearGradient(
    //       colors: [Color(0xffFFEAE3), Color(0xffF6F4F3)],
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //     ),
    //     colorBehindNavBar: AppColors.gradientStart,
    //   ),
    //   handleAndroidBackButtonPress: true, // Default is true.
    //   resizeToAvoidBottomInset:
    //       true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
    //   stateManagement: true, // Default is true.
    //   hideNavigationBarWhenKeyboardAppears: true,
    //   padding: const EdgeInsets.only(top: 2),
    //   backgroundColor: Colors.grey.shade900,
    //   isVisible: true,
    //   animationSettings: const NavBarAnimationSettings(
    //     navBarItemAnimation: ItemAnimationSettings(
    //       // Navigation Bar's items animation properties.
    //       duration: Duration(milliseconds: 400),
    //       curve: Curves.ease,
    //     ),
    //     screenTransitionAnimation: ScreenTransitionAnimationSettings(
    //       // Screen transition animation on change of selected tab.
    //       animateTabTransition: true,
    //       duration: Duration(milliseconds: 200),
    //       screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
    //     ),
    //   ),
    //   confineToSafeArea: true,
    //   // popAllScreensOnTapOfSelectedTab: true,
    //   // itemAnimationProperties: const ItemAnimationProperties(
    //   //   duration: Duration(milliseconds: 200),
    //   //   curve: Curves.easeInOut,
    //   // ),
    //   // screenTransitionAnimation: const ScreenTransitionAnimation(
    //   //   animateTabTransition: true,
    //   //   duration: Duration(milliseconds: 200),
    //   //   curve: Curves.easeInOut,
    //   // ),
    // );
  }
}
