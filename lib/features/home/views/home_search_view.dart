// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/search_textfield.dart';
import '../components/home_icon_tile.dart';
import '../components/home_section_header.dart';
import '../components/service_utils.dart';
import '../controllers/home_controller.dart';
import '../models/banner_model.dart';
import '../models/quick_action_model.dart';
import '../utils/banner_redirect_mapper.dart';

class HomeSearchView extends HookConsumerWidget {
  const HomeSearchView({super.key});

  static const Color _pageBackground = Color(0xFFFFF0EC);
  static const Color _searchBorder = Color(0xFFD2D2D2);
  static const Color _cardBorder = Color(0xFFE3E3E3);
  static const Color _cardCircle = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState('');
    final isLoading = useState(false);
    final hasFetched = useState(false);
    final error = useState<String?>(null);
    final results = useState<List<QuickActionCategory>>([]);
    final banners = useState<List<BannerModel>>([]);
    final bannerError = useState<String?>(null);
    final bannerPage = useState(0);
    final requestId = useRef(0);
    final debounceRef = useRef<Timer?>(null);
    final bannerController =
        useMemoized(() => PageController(viewportFraction: 1), const []);

    useEffect(() {
      Future<void> fetchBanners() async {
        bannerError.value = null;
        try {
          banners.value = await ref
              .read(homeRepositoryProvider)
              .fetchExploreAllServicesBanners(lang: 'en');
        } catch (_) {
          bannerError.value = 'Failed to load banner.';
        }
      }

      Future.microtask(fetchBanners);
      return null;
    }, const []);

    useEffect(() {
      if (banners.value.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!bannerController.hasClients) return;
        final next = (bannerPage.value + 1) % banners.value.length;
        bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [banners.value.length]);

    useEffect(() {
      final currentRequestId = ++requestId.value;

      void fetch() async {
        isLoading.value = true;
        error.value = null;
        try {
          final data = await ref
              .read(homeRepositoryProvider)
              .fetchQuickActions(search: query.value.trim());
          if (currentRequestId != requestId.value) return;
          results.value = data.categories;
          hasFetched.value = true;
        } catch (_) {
          if (currentRequestId != requestId.value) return;
          error.value = 'Failed to fetch services. Please try again.';
          hasFetched.value = true;
        } finally {
          if (currentRequestId == requestId.value) {
            isLoading.value = false;
          }
        }
      }

      debounceRef.value?.cancel();
      debounceRef.value = Timer(const Duration(milliseconds: 300), fetch);

      return () {
        debounceRef.value?.cancel();
      };
    }, [query.value]);

    void handleServiceTap(String serviceName) {
      final normalized = serviceName.trim().toLowerCase();
      if (normalized == 'credit card') {
        context.push(RouteConstants.creditCardMyCards);
      } else if (normalized == 'mobile prepaid') {
        context.push(RouteConstants.mobilePrepaid);
      } else if (normalized == 'digital gold') {
        context.push('${RouteConstants.digitalGold}?entry=home');
      } else if (normalized == 'digital silver') {
        context.push(
          '${RouteConstants.digitalGold}?metal=silver&entry=home',
        );
      } else {
        context.push(RouteConstants.billerListing, extra: serviceName);
      }
    }

    final groupedCategories = _visibleCardCategories(results.value);
    final rechargeCategory = _findGrouped(
      groupedCategories,
      'Recharge',
    );

    return Scaffold(
      backgroundColor: _pageBackground,
      body: Column(
        children: [
          MyAppBar(
            title: 'All Services',
            showHelp: true,
            onBack: () => Navigator.of(context).pop(),
            onHelp: () => context.push(RouteConstants.faq),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: 12.h + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: SearchTextfield(
                    hintText: 'Search Services',
                    controller: searchController,
                    height: 60.h,
                    borderRadius: 12.r,
                    borderColor: _searchBorder,
                    focusedBorderColor: _searchBorder,
                    fillColor: Colors.white,
                    hintFontSize: 14.sp,
                    prefixIconSize: 24.w,
                    prefixIconPadding: EdgeInsets.only(
                      left: 20.w,
                      right: 8.w,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(
                      0,
                      18.h,
                      20.w,
                      18.h,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 8.w),
                      child: Image.asset(
                        FileConstants.search,
                        width: 24.w,
                        height: 24.h,
                        color: AppColors.primary,
                        fit: BoxFit.contain,
                      ),
                    ),
                    onChange: (value) {
                      query.value = value;
                    },
                  ),
                ),
                SizedBox(height: 12.h),
                if (bannerError.value == null && banners.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: SizedBox(
                        height: 80.h,
                        child: PageView.builder(
                          controller: bannerController,
                          padEnds: false,
                          onPageChanged: (page) => bannerPage.value = page,
                          itemCount: banners.value.length,
                          itemBuilder: (_, index) {
                            final banner = banners.value[index];
                            return GestureDetector(
                              onTap: () => BannerRedirectMapper.handle(
                                context,
                                banner.redirectUrl,
                              ),
                              child: AppNetworkImage(
                                url: banner.image,
                                width: 392.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 8.h),
                if (isLoading.value)
                  const _HomeSearchLoadingSkeleton()
                else if (error.value != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    child: Text(
                      error.value!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                    ),
                  )
                else if (hasFetched.value && groupedCategories.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    child: Text(
                      'No services found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                    ),
                  )
                else if (groupedCategories.isNotEmpty) ...[
                  if (query.value.trim().isEmpty && rechargeCategory != null)
                    _FeaturedRechargeStrip(
                      category: rechargeCategory,
                      onServiceTap: handleServiceTap,
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                    child: Column(
                      children: [
                        for (final category in groupedCategories)
                          _CategorySection(
                            key: ValueKey(category.category),
                            category: category,
                            onServiceTap: handleServiceTap,
                          ),
                      ],
                    ),
                  ),
                ]
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchLoadingSkeleton extends StatelessWidget {
  const _HomeSearchLoadingSkeleton();

  static const _mockFeatured = QuickActionCategory(
    category: 'Recharge',
    services: [
      QuickActionService(name: 'Mobile Prepaid'),
      QuickActionService(name: 'Mobile Postpaid'),
      QuickActionService(name: 'FASTag Recharge'),
      QuickActionService(name: 'EV Recharge'),
      QuickActionService(name: 'Fleet Card Recharge'),
    ],
  );

  static const _mockCategories = [
    QuickActionCategory(
      category: 'Recharge',
      services: [
        QuickActionService(name: 'Mobile Prepaid'),
        QuickActionService(name: 'Mobile Postpaid'),
        QuickActionService(name: 'FASTag Recharge'),
        QuickActionService(name: 'EV Recharge'),
        QuickActionService(name: 'Fleet Card Recharge'),
        QuickActionService(name: 'NCMC Recharge'),
      ],
    ),
    QuickActionCategory(
      category: 'Utility Bills',
      services: [
        QuickActionService(name: 'Electricity'),
        QuickActionService(name: 'Credit Card'),
        QuickActionService(name: 'DTH'),
        QuickActionService(name: 'Fastag'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: IgnorePointer(
        child: Column(
          children: [
            const _FeaturedRechargeStrip(
              category: _mockFeatured,
              onServiceTap: _noopServiceTap,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              child: Column(
                children: _mockCategories
                    .map(
                      (category) => _CategorySection(
                        category: category,
                        onServiceTap: _noopServiceTap,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _noopServiceTap(String _) {}
}

class _FeaturedRechargeStrip extends StatelessWidget {
  const _FeaturedRechargeStrip({
    required this.category,
    required this.onServiceTap,
  });

  final QuickActionCategory category;
  final void Function(String serviceName) onServiceTap;

  @override
  Widget build(BuildContext context) {
    final services = category.services.take(5).toList();
    if (services.isEmpty) return const SizedBox.shrink();

    return ColoredBox(
      color: HomeSearchView._pageBackground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recharge',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                height: 1,
                letterSpacing: 16.sp * -0.02,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 26.h),
            SizedBox(
              width: 392.w,
              height: 107.h,
              child: Row(
                children: [
                  for (var i = 0; i < services.length; i++) ...[
                    if (i > 0) SizedBox(width: 20.w),
                    _FeaturedRechargeItem(
                      service: services[i],
                      onTap: () => onServiceTap(services[i].name),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedRechargeItem extends StatelessWidget {
  const _FeaturedRechargeItem({
    required this.service,
    required this.onTap,
  });

  final QuickActionService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final asset = localAssetForService(service.name);
    final label = displayServiceName(service.name);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 62.4.w,
        height: 107.h,
        child: Column(
          children: [
            Container(
              width: 62.4.w,
              height: 62.4.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: asset != null
                    ? Image.asset(
                        asset,
                        width: 32.w,
                        height: 32.h,
                        fit: BoxFit.contain,
                      )
                    : AppNetworkImage(
                        url: service.icon,
                        width: 32.w,
                        height: 32.h,
                        fit: BoxFit.contain,
                        showShimmer: false,
                      ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 18 / 12,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    super.key,
    required this.category,
    required this.onServiceTap,
  });

  final QuickActionCategory category;
  final void Function(String serviceName) onServiceTap;

  @override
  Widget build(BuildContext context) {
    const int columns = 4;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: category.category,
            padding: EdgeInsets.zero,
            titleStyle: GoogleFonts.bricolageGrotesque(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              height: 1,
              letterSpacing: 18.sp * -0.02,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 20.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: HomeSearchView._cardBorder,
                  width: 1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.w;
                  final itemWidth =
                      (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 18.h,
                    children: [
                      for (final service in category.services)
                        SizedBox(
                          width: itemWidth,
                          child: HomeIconTile(
                            label: displayServiceName(service.name),
                            iconUrl: service.icon,
                            localAsset: localAssetForService(service.name),
                            iconSize: 28,
                            circleSize: 64.r,
                            circleColor: HomeSearchView._cardCircle,
                            onTap: () => onServiceTap(service.name),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllServicesBox {
  const _AllServicesBox({
    required this.title,
    required this.matchesService,
  });

  final String title;
  final bool Function(String serviceName) matchesService;
}

const _cardBoxes = [
  _AllServicesBox(title: 'Recharge', matchesService: _isRechargeService),
  _AllServicesBox(title: 'Utility Bills', matchesService: _isUtilityService),
  _AllServicesBox(title: 'Financial', matchesService: _isFinancialService),
  _AllServicesBox(
    title: 'Pay Via Credit Card (Education)',
    matchesService: _isEducationService,
  ),
  _AllServicesBox(title: 'Insurance', matchesService: _isInsuranceService),
  _AllServicesBox(title: 'Rent & Property', matchesService: _isRentService),
];

List<QuickActionCategory> _visibleCardCategories(
  List<QuickActionCategory> categories,
) {
  final allServices = <String, QuickActionService>{};
  for (final category in categories) {
    for (final service in category.services) {
      final key = service.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      allServices.putIfAbsent(key, () => service);
    }
  }

  final visible = <QuickActionCategory>[];
  for (final box in _cardBoxes) {
    final services = allServices.values
        .where((service) => box.matchesService(service.name))
        .toList();
    if (services.isEmpty) continue;
    visible.add(
      QuickActionCategory(
        category: box.title,
        services: box.title == 'Recharge'
            ? _sortRechargeServices(services)
            : services,
      ),
    );
  }
  return visible;
}

QuickActionCategory? _findGrouped(
  List<QuickActionCategory> categories,
  String title,
) {
  for (final category in categories) {
    if (category.category == title) return category;
  }
  return null;
}

List<QuickActionService> _sortRechargeServices(
  List<QuickActionService> services,
) {
  const order = [
    'mobile prepaid',
    'mobile postpaid',
    'fastag',
    'ev recharge',
    'fleet',
    'ncmc',
  ];
  int rank(QuickActionService service) {
    final n = service.name.trim().toLowerCase();
    for (var i = 0; i < order.length; i++) {
      if (n.contains(order[i])) return i;
    }
    return order.length;
  }

  final sorted = [...services]..sort((a, b) => rank(a).compareTo(rank(b)));
  return sorted;
}

bool _isEducationService(String name) {
  final n = name.trim().toLowerCase();
  return n.contains('school fee') ||
      n.contains('college fee') ||
      n.contains('tuition') ||
      n.contains('tution') ||
      n.contains('education fee');
}

bool _isInsuranceService(String name) {
  final n = name.trim().toLowerCase();
  return n.contains('insurance') ||
      n == 'general' ||
      n == 'health' ||
      n == 'life';
}

bool _isRentService(String name) {
  final n = name.trim().toLowerCase();
  return n.contains('rent') || n == 'rental';
}

bool _isRechargeService(String name) {
  final n = name.trim().toLowerCase();
  return n.contains('mobile prepaid') ||
      n.contains('mobile postpaid') ||
      n.contains('fastag') ||
      n.contains('fast tag') ||
      n.contains('ev recharge') ||
      n.contains('fleet') ||
      n.contains('ncmc');
}

bool _isFinancialService(String name) {
  final n = name.trim().toLowerCase();
  if (_isEducationService(name)) return false;
  return n.contains('credit card') ||
      n.contains('digital gold') ||
      n.contains('digital silver') ||
      n == 'gold' ||
      n == 'silver' ||
      n.contains('loan') ||
      n.contains('municipal tax') ||
      n.contains('echallan') ||
      n.contains('e-challan') ||
      n.contains('e challan') ||
      n.contains('nps') ||
      n.contains('pension') ||
      n.contains('forex') ||
      n.contains('agent collection') ||
      n.contains('b2b');
}

bool _isUtilityService(String name) {
  final n = name.trim().toLowerCase();
  if (_isRechargeService(name) ||
      _isEducationService(name) ||
      _isInsuranceService(name) ||
      _isRentService(name) ||
      _isFinancialService(name)) {
    return false;
  }
  return n.contains('electric') ||
      n.contains('lpg') ||
      n.contains('piped gas') ||
      n.contains('pipe gas') ||
      n.contains('book gas') ||
      n.contains('prepaid meter') ||
      n.contains('cable') ||
      n.contains('dth') ||
      n.contains('broadband') ||
      n.contains('landline') ||
      n.contains('housing') ||
      n.contains('municipal service') ||
      n.contains('water') ||
      n.contains('gas');
}

