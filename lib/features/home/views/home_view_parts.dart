// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_element, unused_element_parameter, unused_local_variable

part of 'home_view.dart';

class _Dot extends StatelessWidget {
  const _Dot({
    required this.active,
    this.onBanner = false,
  });
  final bool active;
  final bool onBanner;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (onBanner) {
      color = active ? Colors.white : Colors.white.withOpacity(0.45);
    } else {
      color = active ? AppColors.primary : AppColors.lightBorder;
    }
    return Container(
      width: (active ? 14 : (onBanner ? 6 : 8)).w,
      height: (onBanner ? 6 : 8).h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40.r),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onTap,
    this.icon,
    this.iconAsset,
    this.badgeCount,
    this.size = 40,
    this.iconSize = 20,
    this.iconColor,
  }) : assert(icon != null || iconAsset != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAsset;
  final int? badgeCount;
  final double size;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size.r;
    final resolvedIconSize = iconSize.r;
    final resolvedIconColor = iconColor ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        height: resolvedSize,
        width: resolvedSize,
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: iconAsset != null
                  ? Image.asset(
                      iconAsset!,
                      height: resolvedIconSize,
                      width: resolvedIconSize,
                      color: resolvedIconColor,
                    )
                  : Icon(
                      icon,
                      size: resolvedIconSize,
                      color: resolvedIconColor,
                    ),
            ),
            if ((badgeCount ?? 0) > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    (badgeCount ?? 0) > 9 ? '9+' : '${badgeCount ?? 0}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PagerDots extends StatelessWidget {
  const _PagerDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(active: true),
        SizedBox(width: 6),
        _Dot(active: false),
        SizedBox(width: 6),
        _Dot(active: false),
      ],
    );
  }
}

class _BottomIcon extends StatelessWidget {
  const _BottomIcon({
    required this.asset,
    this.size = 24,
    this.color,
    this.yOffset = 0,
  });
  final String asset;
  final double size;
  final Color? color;
  final double yOffset;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (size * dpr).round();
    final icon = SizedBox(
      height: size,
      width: size,
      child: Center(
        child: Image.asset(
          asset,
          height: size,
          width: size,
          fit: BoxFit.cover,
          color: color,
          cacheWidth: cacheW,
          cacheHeight: cacheW,
        ),
      ),
    );
    if (yOffset == 0) return icon;
    return Transform.translate(offset: Offset(0, yOffset), child: icon);
  }
}

class _BottomIconWithBadge extends StatelessWidget {
  const _BottomIconWithBadge({
    required this.asset,
    this.size = 24,
    this.color,
    this.yOffset = 0,
  });

  final String asset;
  final double size;
  final Color? color;
  final double yOffset;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationBadgeService.unreadCount,
      builder: (context, unreadCount, _) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cacheW = (size * dpr).round();
        final wrapper = size + 10;
        return SizedBox(
          height: wrapper,
          width: wrapper,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, yOffset),
                child: Image.asset(
                  asset,
                  height: size,
                  width: size,
                  fit: BoxFit.contain,
                  color: color,
                  cacheWidth: cacheW,
                  cacheHeight: cacheW,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 0,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GradientFabIcon extends StatelessWidget {
  const _GradientFabIcon({
    required this.asset,
    this.size = 24,
    this.iconColor,
  });
  final String asset;
  final double size;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.r,
      width: 48.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Image.asset(
          asset,
          height: 26.h,
          width: 24.w,
          color: iconColor ?? Colors.white,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _HomeNavTabItem extends StatelessWidget {
  const _HomeNavTabItem({
    required this.asset,
    required this.label,
    required this.isActive,
    this.showBadge = false,
  });

  final String asset;
  final String label;
  final bool isActive;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF000000) : const Color(0xFF6D6D6D);
    final icon = Image.asset(
      asset,
      height: 24.r,
      width: 24.r,
      fit: BoxFit.contain,
    );
    return SizedBox(
      width: 61.w,
      height: 45.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showBadge)
            _BottomIconWithBadge(
              asset: asset,
              size: 24.r,
            )
          else
            icon,
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(
              color: color,
              fontSize: 14.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              height: 1,
              letterSpacing: -0.28,
            ),
          ),
        ],
      ),
    );
  }
}

class _EcoinsGlyph extends StatelessWidget {
  const _EcoinsGlyph({this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      FileConstants.favicon,
      width: size.w,
      height: size.h,
      fit: BoxFit.contain,
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.initials,
    required this.walletBalance,
    this.isWalletLoading = false,
    this.hasWalletError = false,
    required this.onSearchTap,
    required this.onReferTap,
    required this.onProfileTap,
    this.compact = false,
  });

  final String initials;
  final double? walletBalance;
  final bool isWalletLoading;
  final bool hasWalletError;
  final VoidCallback onSearchTap;
  final VoidCallback onReferTap;
  final VoidCallback onProfileTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.plusJakartaSans(
      textStyle: Theme.of(context).textTheme.bodySmall,
    );
    final resolvedWalletBalance = walletBalance;
    final displayBalance = resolvedWalletBalance == null
        ? '--'
        : resolvedWalletBalance == resolvedWalletBalance.roundToDouble()
            ? resolvedWalletBalance.toStringAsFixed(0)
            : resolvedWalletBalance.toStringAsFixed(2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        SizedBox(
      width: 392.w,
      height: 40.h,
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: _ProfileAvatar(
                initials: initials,
                size: 40,
              ),
            ),
            SizedBox(width: 8.w),
            _HeaderIconButton(
              icon: Icons.search,
              size: 40,
              iconSize: 16,
              iconColor: const Color(0xFFDD5428),
              onTap: onSearchTap,
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onReferTap,
              child: Container(
                width: 128.w,
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  borderRadius: BorderRadius.circular(27.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      FileConstants.giftIcon,
                      height: 16.r,
                      width: 16.r,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Refer & Earn',
                      style: textStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () {
                context.push(RouteConstants.referAndEarnWallet);
              },
              child: Container(
                width: 76.w,
                height: 36.h,
                padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _EcoinsGlyph(size: 24),
                    SizedBox(width: 6.w),
                    if (isWalletLoading)
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: AppColors.textPrimary,
                        ),
                      )
                    else
                      Flexible(
                        child: Text(
                          displayBalance,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bricolageGrotesque(
                            color: hasWalletError
                                ? AppColors.textPrimary.withOpacity(0.55)
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            height: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
        ),
        SizedBox(height: 18.h),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials, required this.size});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.r,
      width: size.r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.plusJakartaSans(
            textStyle: Theme.of(context).textTheme.bodySmall,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(18.r),
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  height: 22.r,
                  width: 22.r,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 12.r,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HomeIconGrid extends StatelessWidget {
  const _HomeIconGrid({
    required this.services,
    required this.onTap,
    this.maxItems = 8,
    this.columns = 4,
    this.tileWidth = 64,
  });

  final List<QuickActionService> services;
  final Future<void> Function(String serviceName) onTap;
  final int maxItems;
  final int columns;
  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    final visibleItems = services.take(maxItems).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final spacing = 12.w;
        final computedTileSize = (maxWidth - spacing * (columns - 1)) / columns;
        final tileSize =
            computedTileSize > tileWidth.r ? tileWidth.r : computedTileSize;
        return Wrap(
          spacing: spacing.w,
          runSpacing: 16.h,
          children: List.generate(visibleItems.length, (index) {
            final service = visibleItems[index];
            return SizedBox(
              width: tileSize,
              child: HomeIconTile(
                label: service.name,
                iconUrl: service.icon,
                offer: service.offers,
                onTap: () async {
                  await onTap(service.name);
                },
              ),
            );
          }),
        );
      },
    );
  }
}

List<QuickActionService> _insuranceServicesInDisplayOrder(
  List<QuickActionService> services,
) {
  final remaining = List<QuickActionService>.from(services);
  QuickActionService? take(bool Function(String name) match) {
    final index = remaining.indexWhere(
      (service) => match(service.name.trim().toLowerCase()),
    );
    if (index < 0) return null;
    return remaining.removeAt(index);
  }

  return [
    ...[
      take((name) => name.contains('life')),
      take((name) => name.contains('health')),
      take((name) => name.contains('general')),
      take((name) => name.contains('rent')),
    ].whereType<QuickActionService>(),
    ...remaining,
  ];
}

class _CurvedIconGrid extends StatelessWidget {
  const _CurvedIconGrid({
    required this.services,
    required this.onTap,
    this.maxItems = 4,
    this.labelBuilder,
  });

  final List<QuickActionService> services;
  final Future<void> Function(String serviceName) onTap;
  final int maxItems;
  final String Function(QuickActionService service)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final visibleItems = services.take(maxItems).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.w;
        return SizedBox(
          height: 116.h,
          child: Row(
            children: List.generate(4, (index) {
              final service =
                  index < visibleItems.length ? visibleItems[index] : null;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : spacing / 2,
                    right: index == 3 ? 0 : spacing / 2,
                  ),
                  child: service == null
                      ? const SizedBox.shrink()
                      : _CurvedIconTile(
                          label: labelBuilder?.call(service) ?? service.name,
                          iconUrl: service.icon ?? '',
                          onTap: () async {
                            await onTap(service.name);
                          },
                        ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _CurvedIconTile extends StatelessWidget {
  const _CurvedIconTile({
    required this.label,
    required this.iconUrl,
    required this.onTap,
  });

  final String label;
  final String iconUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelWords = label.trim().split(RegExp(r'\s+'));
    final isTwoWordLabel = labelWords.length == 2;
    final displayLabel =
        isTwoWordLabel ? '${labelWords.first}\n${labelWords.last}' : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xffEAEAEA), width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  FileConstants.bottomOrangeCurve,
                  height: 8.h,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 12.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40.r,
                      width: 40.r,
                      alignment: Alignment.center,
                      child: AppNetworkImage(
                        url: iconUrl,
                        width: 36.r,
                        height: 36.r,
                        fit: BoxFit.contain,
                        showShimmer: false,
                        errorWidget: Image.asset(
                          FileConstants.appLogo,
                          height: 36.r,
                          width: 36.r,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Flexible(
                      child: Center(
                        child: Text(
                          displayLabel,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmallSemibold(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayBillsCard extends StatelessWidget {
  const _PayBillsCard({
    required this.services,
    required this.onTap,
    required this.onExploreTap,
    this.isCreditCardLoading = false,
  });

  final List<QuickActionService> services;
  final Future<void> Function(String serviceName) onTap;
  final VoidCallback onExploreTap;
  final bool isCreditCardLoading;

  QuickActionService? _findService(Set<String> used, List<String> names) {
    for (final name in names) {
      for (final service in services) {
        if (service.name == name && !used.contains(service.name)) {
          used.add(service.name);
          return service;
        }
      }
    }
    return null;
  }

  QuickActionService? _nextUnused(Set<String> used) {
    for (final service in services) {
      if (!used.contains(service.name)) {
        used.add(service.name);
        return service;
      }
    }
    return null;
  }

  String _labelForService(QuickActionService service) {
    final lower = service.name.trim().toLowerCase();
    if (lower.contains('electric')) return 'Electricity Bill';
    if (lower.contains('prepaid') ||
        (lower.contains('mobile') && lower.contains('recharge'))) {
      return 'Mobile Recharge';
    }
    if (lower.contains('fastag') || lower.contains('fast tag')) {
      return 'FASTag Recharge';
    }
    if (lower.contains('book') &&
        (lower.contains('lpg') || lower.contains('gas'))) {
      return 'Book LPG';
    }
    return service.name;
  }

  Widget _serviceTile(QuickActionService service) {
    return HomeIconTile(
      label: _labelForService(service),
      iconUrl: service.icon,
      offer: service.offers,
      labelSpacing: 4.h,
      showHalfRing: _isBookGasService(service),
      isLoading: isCreditCardLoading && _isCreditCardService(service),
      onTap: () async {
        await onTap(service.name);
      },
    );
  }

  bool _isBookGasService(QuickActionService service) {
    final name = service.name.trim().toLowerCase();
    // Ring highlight only for "Book Gas" style actions (not all gas types).
    return name.contains('book') &&
        (name.contains('gas') || name.contains('lpg'));
  }

  bool _isCreditCardService(QuickActionService service) {
    return service.name.trim().toLowerCase() == 'credit card';
  }

  @override
  Widget build(BuildContext context) {
    final used = <String>{};

    final electricity = _findService(used, const ['Electricity']);
    final recharge = _findService(
      used,
      const ['Mobile Prepaid', 'Mobile Postpaid', 'Recharge'],
    );
    final fastag = _findService(used, const ['Fastag', 'FASTag']);
    final credit = _findService(used, const ['Credit Card']);
    final bookGas = _findService(
          used,
          const ['LPG Gas', 'Book Gas Cylinder', 'Pipe Gas', 'Book Gas'],
        ) ??
        _nextUnused(used);

    final topRow = <QuickActionService?>[
      electricity ?? _nextUnused(used),
      recharge ?? _nextUnused(used),
      fastag ?? _nextUnused(used),
      credit ?? _nextUnused(used),
    ];

    const imageAspectRatio = 1960 / 1380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = width / imageAspectRatio - 4.h;
            final tileWidth = width * 0.18;
            final bookTileWidth = width * 0.2;
            final horizontalInset = width * 0.06;
            final topRowSpacing =
                (width - (horizontalInset * 2) - (tileWidth * 4)) / 3;
            final firstTileCenter = horizontalInset + (tileWidth / 2);

            Widget positionedTile({
              required double x,
              required double y,
              required QuickActionService? service,
              required double tileW,
            }) {
              if (service == null) return const SizedBox.shrink();
              return Positioned(
                left: x - (tileW / 2),
                top: y,
                width: tileW,
                child: _serviceTile(service),
              );
            }

            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      FileConstants.homeIconSection,
                      fit: BoxFit.fill,
                    ),
                  ),
                  positionedTile(
                    x: firstTileCenter,
                    y: height * 0.08,
                    service: topRow[0],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: firstTileCenter + tileWidth + topRowSpacing,
                    y: height * 0.08,
                    service: topRow[1],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: firstTileCenter + ((tileWidth + topRowSpacing) * 2),
                    y: height * 0.08,
                    service: topRow[2],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: firstTileCenter + ((tileWidth + topRowSpacing) * 3),
                    y: height * 0.08,
                    service: topRow[3],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: width * 0.15,
                    y: height * 0.5,
                    service: bookGas,
                    tileW: bookTileWidth,
                  ),
                  if (bookGas != null)
                    Positioned(
                      left: 112.w,
                      top: height * 0.54,
                      width: 280.w,
                      height: 41.h,
                      child: _PromoStrip(
                        asset: FileConstants.bookLpgStrip,
                      ),
                    ),
                  Positioned(
                    right: width * 0.01,
                    bottom: height * 0.01,
                    child: _ExploreUtilitiesRow(onTap: onExploreTap),
                  ),
                ],
              ),
            );
          },
        ),
        // SizedBox(height: 18.h),
        // const _ReferStrip(),
      ],
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const _PromoStrip({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.r),
        bottomLeft: Radius.circular(8.r),
      ),
      child: Container(
        width: 280.w,
        height: 41.h,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        color: const Color(0xFF193459),
        child: Transform.translate(
          offset: Offset(0, -4.h),
          child: SizedBox(
            width: 270.w,
            height: 24.h,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Book LPG • Get ',
                    style: GoogleFonts.bricolageGrotesque(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      height: 24 / 16,
                      letterSpacing: 0,
                    ),
                  ),
                  TextSpan(
                    text: '10% OFF',
                    style: GoogleFonts.bricolageGrotesque(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      height: 24 / 16,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreUtilitiesRow extends StatelessWidget {
  const _ExploreUtilitiesRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 52.h,
        width: 270.w,
        padding: EdgeInsets.fromLTRB(44.w, 12.h, 44.w, 12.h),
        decoration: BoxDecoration(
          color: const Color(0x66FFE2D9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Explore All Utilities',
                  style: GoogleFonts.bricolageGrotesque(
                    color: const Color(0xFFDD5428),
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 1,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              height: 22.r,
              width: 22.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 12.r,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferStrip extends StatelessWidget {
  const _ReferStrip();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ReferAndEarnView(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          image: DecorationImage(
            image: AssetImage(FileConstants.referBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 18.r,
              width: 18.r,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                FileConstants.coin_3d,
                height: 12.r,
                width: 12.r,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Refer Your First Friend And Grab 1000 E-Coins',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  color: Colors.white,
                  letterSpacing: -0.25,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({
    required this.label,
    required this.iconAsset,
    required this.arrowAsset,
    required this.borderColor,
    required this.textColor,
    this.backgroundGradient,
  });

  final String label;
  final String iconAsset;
  final String arrowAsset;
  final Color borderColor;
  final Color textColor;
  final Gradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57.5.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundGradient == null ? Colors.white : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 24.r,
            width: 24.r,
            child: Image.asset(
              iconAsset,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                textStyle: Theme.of(context).textTheme.bodySmall,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            height: 18.r,
            width: 18.r,
            child: Image.asset(
              arrowAsset,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({
    required this.asset,
    required this.height,
    this.fit = BoxFit.contain,
  });
  final String asset;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();
    return Image.asset(
      asset,
      height: height,
      width: double.infinity,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
    );
  }
}

class InsuranceBannerCarousel extends HookWidget {
  const InsuranceBannerCarousel({
    super.key,
    required this.onApply,
    this.banners = const [],
    this.isLoading = false,
  });

  final VoidCallback onApply;
  final List<BannerModel> banners;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    final currentIndex = useState(0);
    final total = banners.length;

    useEffect(() {
      if (total < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!controller.hasClients) return;
        final next = (currentIndex.value + 1) % total;
        controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [total]);

    if (total == 0) return const SizedBox.shrink();

    return Stack(
      children: [
        PageView.builder(
          controller: controller,
          physics: total > 1
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: total,
          onPageChanged: (index) => currentIndex.value = index,
          itemBuilder: (context, index) {
            final banner = banners[index];
            return GestureDetector(
              onTap: () => BannerRedirectMapper.handle(
                context,
                banner.redirectUrl,
              ),
              child: AppNetworkImage(
                url: banner.image,
                width: 440.w,
                height: 180.h,
                fit: BoxFit.cover,
                placeholder: AppNetworkImage(
                  url: '',
                  width: 440.w,
                  height: 180.h,
                ),
              ),
            );
          },
        ),
        if (total > 1)
          Positioned(
            left: 24.w,
            bottom: 16.h,
            child: Row(
              children: List.generate(
                total,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 6.h,
                    width: currentIndex.value == index ? 14.w : 6.w,
                    decoration: BoxDecoration(
                      color: currentIndex.value == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InsuranceBannerItem extends StatelessWidget {
  const _InsuranceBannerItem({
    required this.image,
    required this.onApply,
    required this.currentIndex,
    required this.total,
    this.showPagerDots = true,
  });

  final String image;
  final VoidCallback onApply;
  final int currentIndex;
  final int total;
  final bool showPagerDots;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8A4B),
            Color(0xFF0C6B3B),
          ],
        ),
      ),
      child: Row(
        children: [
          /// LEFT CONTENT
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Your Future',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Health, Motor & Life Insurance In\nMinutes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 10.h),

                /// APPLY BUTTON
                InkWell(
                  onTap: onApply,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFDD5428),
                          Color(0xFF772D16),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Apply Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.north_east, size: 14.r, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                if (showPagerDots)
                Row(
                  children: List.generate(
                    total,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: 4.w),
                      height: 6.h,
                      width: currentIndex == index ? 14.w : 6.w,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          /// RIGHT IMAGE
          SizedBox(
            height: 96.h,
            width: 120.w,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsuranceBanner extends StatelessWidget {
  const _InsuranceBanner({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8A4B),
            Color(0xFF0C6B3B),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Your Future',
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Health, Motor & Life Insurance In\nMinutes',
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 10.h),
                InkWell(
                  onTap: onApply,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFDD5428),
                          Color(0xFF772D16),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Apply Now',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.north_east,
                          size: 14.r,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 10.h,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            height: 96.h,
            width: 120.w,
            child: Image.asset(
              FileConstants.homeBannerGif,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// class _MiniImageCard extends StatelessWidget {
//   const _MiniImageCard({
//     required this.asset,
//     required this.title,
//     required this.onTap,
//   });
//   final String asset;
//   final String title;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: AppColors.lightBorder),
//         ),
//         child: Row(
//           children: [
//             Image.asset(asset, height: 30.h, width: 30.h, fit: BoxFit.contain),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: Text(
//                 title,
//                 style: GoogleFonts.plusJakartaSans(
//                   textStyle: Theme.of(context).textTheme.bodySmall,
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Container(
//               height: 20.r,
//               width: 20.r,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.chevron_right,
//                 size: 14.r,
//                 color: AppColors.primary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.gradientBorder,
    this.iconWidth = 24,
    this.iconHeight = 24,
    this.arrowColor = AppColors.primary,
  });

  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradientBorder;
  final double iconWidth;
  final double iconHeight;
  final Color arrowColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 188.w,
        height: 57.5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: gradientBorder,
        ),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: gradientBorder == null
                ? Border.all(
                    color: borderColor ?? AppColors.lightBorder,
                    width: 0.5,
                  )
                : null,
          ),
          margin: gradientBorder == null
              ? EdgeInsets.zero
              : const EdgeInsets.all(0.5),
          child: Row(
            children: [
              Image.asset(
                asset,
                height: iconHeight.h,
                width: iconWidth.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        color: AppColors.textPrimary.withOpacity(0.6),
                        fontSize: 11.sp,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 24.r,
                width: 24.r,
                decoration: BoxDecoration(
                  color: arrowColor,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.north_east_rounded,
                  size: 12.r,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Image.asset(FileConstants.faqIcon,
                height: 22.r, width: 22.r, fit: BoxFit.contain),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Container(
              height: 28.r,
              width: 28.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.north_east_rounded,
                size: 14.r,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends HookConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final homeRepository = useMemoized(HomeRepository.new);
    final hasInternet = ref.watch(connectivityStatusProvider).value ?? true;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bannerCacheWidth = (screenWidth * devicePixelRatio).round();

    final didShowCompleteProfile = useRef(false);
    final didShowTemporaryBlock = useRef(false);
    final didShowReminderPopup = useRef(false);
    // Track auth transitions across navigation; initialize to false so that if
    // Home is already mounted (behind login) we still refresh once on login.
    final wasAuthenticated = useRef<bool>(false);

    useEffect(() {
      Future.microtask(() {
        ref.read(homeControllerProvider.notifier).fetchQuickActionsIfNeeded();
        ref
            .read(homeControllerProvider.notifier)
            .fetchAllQuickActionsIfNeeded();
        ref.read(spinOptionsControllerProvider.notifier).fetchSpinOptions();
        ref.read(profileControllerProvider.notifier).fetchProfileIfNeeded();
      });
      return null;
    }, const []);

    // If Home stays mounted across login (ex: PIN unlock/login), the initial
    // `useEffect(const [])` won't re-run. Trigger a refresh when auth flips
    // from unauthenticated -> authenticated.
    useEffect(() {
      final prev = wasAuthenticated.value;
      final next = authState.isAuthenticated;
      wasAuthenticated.value = next;
      if (prev == false && next == true) {
        Future.microtask(() {
          ref
              .read(homeControllerProvider.notifier)
              .fetchQuickActionsIfNeeded(force: true);
          ref
              .read(homeControllerProvider.notifier)
              .fetchAllQuickActionsIfNeeded(force: true);
          ref
              .read(profileControllerProvider.notifier)
              .fetchProfileIfNeeded(force: true);
        });
      }
      return null;
    }, [authState.isAuthenticated]);

    useEffect(() {
      final needsProfile =
          homeState.isNameEmailExist == false && homeState.quickActions != null;
      if (!needsProfile || didShowCompleteProfile.value) return null;
      didShowCompleteProfile.value = true;
      Future.microtask(() {
        KDialog.instance.openDialog(
          barrierDismissible: false,
          dialog: CompleteProfileDialog(
            onCompleted: () {
              ref
                  .read(profileControllerProvider.notifier)
                  .fetchProfileIfNeeded(force: true);
              ref
                  .read(homeControllerProvider.notifier)
                  .fetchQuickActionsIfNeeded(force: true);
            },
          ),
        );
      });
      return null;
    }, [homeState.isNameEmailExist, homeState.quickActions]);

    final temporaryBlockFlow = _resolveTemporaryBlockFlow(profileState.profile);
    useEffect(() {
      if (temporaryBlockFlow == null || didShowTemporaryBlock.value) {
        return null;
      }
      if (profileState.profile == null) {
        return null;
      }
      didShowTemporaryBlock.value = true;
      Future.microtask(() async {
        if (!context.mounted) return;
        await KDialog.instance.openDialog(
          barrierDismissible: false,
          dialog: TemporaryBlockDialog(
            flowType: temporaryBlockFlow,
            onSupportTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Future.microtask(() {
                if (!context.mounted) return;
                context.push(RouteConstants.helpSupport);
              });
            },
            onPrimaryTap: () {
              final profile = profileState.profile;
              final successRoute =
                  temporaryBlockFlow == TemporaryBlockFlowType.noKyc
                      ? RouteConstants.kycVerification
                      : RouteConstants.temporaryBlockIdentityCompletion;
              final flowQueryValue =
                  temporaryBlockFlow == TemporaryBlockFlowType.noKyc
                      ? 'noKyc'
                      : 'kycVerified';
              Navigator.of(context, rootNavigator: true).pop();
              Future.microtask(() {
                if (!context.mounted) return;
                context.push(
                  '${RouteConstants.temporaryBlockOtp}?flow=$flowQueryValue&phone=${profile?.mobile ?? ''}',
                  extra: OtpVerificationArgs(
                    phoneNumber: profile?.mobile,
                    title: 'Verify Your Identity',
                    heading: 'Verify Your Identity',
                    description:
                        'Enter the OTPs sent to your registered mobile number and email address to verify your identity.',
                    primaryButtonLabel: 'Verify & Continue',
                    successDialogTitle:
                        'Mobile and Email verified successfully',
                    successDialogMessage:
                        'This device has been successfully verified and added to your trusted device list. You can now access your account securely.',
                    successButtonLabel: 'Complete KYC',
                    successRoute: successRoute,
                    successRouteExtra:
                        successRoute == RouteConstants.kycVerification
                            ? false
                            : null,
                    temporaryBlockFlowType: temporaryBlockFlow,
                  ),
                );
              });
            },
          ),
        );
      });
      return null;
    }, [temporaryBlockFlow, profileState.profile?.id]);

    useEffect(() {
      final hasLoadedHome = homeState.quickActions != null;
      final needsProfile = homeState.isNameEmailExist == false && hasLoadedHome;
      if (!hasLoadedHome ||
          needsProfile ||
          temporaryBlockFlow != null ||
          didShowReminderPopup.value) {
        return null;
      }
      didShowReminderPopup.value = true;
      Future.microtask(() async {
        if (!context.mounted) return;
        try {
          final response = await homeRepository.fetchBillReminders(
            page: 1,
            limit: 20,
          );
          if (!context.mounted || !response.status || response.items.isEmpty) {
            return;
          }
          final reminder = response.items.first;
          final biller = Biller(
            billerId: reminder.billerId,
            billerName: reminder.billerName,
            icon: reminder.billerIcon,
          );
          final paymentType = reminder.paymentType.trim();
          final normalizedPaymentType = paymentType.toLowerCase();
          final maskedDigits =
              reminder.maskedIdentifier.replaceAll(RegExp(r'\D'), '');
          final cardLast4 = maskedDigits.length >= 4
              ? maskedDigits.substring(maskedDigits.length - 4)
              : null;
          final reminderIdentifier = _resolveReminderPrefillValue(reminder);
          final reminderMobile = reminder.customerMobile.trim();
          final canAutoFetchReminder = normalizedPaymentType.contains('credit')
              ? reminderMobile.isNotEmpty && cardLast4 != null
              : reminderIdentifier.isNotEmpty;
          await KDialog.instance.openDialog(
            dialog: _HomeReminderDialog(
              data: reminder,
              onPrimaryTap: reminder.canPayNow
                  ? () {
                      Navigator.of(context, rootNavigator: true).pop();
                      ref
                          .read(billerDetailControllerProvider.notifier)
                          .selectBiller(
                            biller,
                            categoryName:
                                paymentType.isNotEmpty ? paymentType : null,
                          );
                      context.push(
                        RouteConstants.billerDetail,
                        extra: BillerDetailArgs(
                          biller: biller,
                          isCreditCard:
                              normalizedPaymentType.contains('credit'),
                          paymentType:
                              paymentType.isNotEmpty ? paymentType : null,
                          mobileNumber: normalizedPaymentType.contains('credit')
                              ? (reminderMobile.isNotEmpty
                                  ? reminderMobile
                                  : null)
                              : (reminderIdentifier.isNotEmpty
                                  ? reminderIdentifier
                                  : null),
                          cardLast4: cardLast4,
                          autoFetchBill: canAutoFetchReminder,
                          autoOpenPaymentSheet: false,
                        ),
                      );
                    }
                  : null,
            ),
          );
        } catch (_) {}
      });
      return null;
    }, [
      homeState.quickActions,
      homeState.isNameEmailExist,
      temporaryBlockFlow,
      homeRepository,
    ]);

    final topBanners = homeState.banners?['top'] ?? [];
    final middleBanners = homeState.banners?['middle'] ?? [];
    final bottomBanners = homeState.banners?['bottom'] ?? [];
    final bankingInvestmentBanners =
        homeState.banners?['banking_investment'] ?? [];

    final topBannerPage = useState(0);
    final topBannerController = useMemoized(() => PageController(), const []);
    useEffect(() {
      if (topBanners.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!topBannerController.hasClients) return;
        final next = (topBannerPage.value + 1) % topBanners.length;
        topBannerController.animateToPage(
          next.toInt(),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [topBanners.length]);

    final quickActions = homeState.quickActions;

    final showBannerPlaceholder = topBanners.isEmpty &&
        homeState.errorMessage == null &&
        (homeState.isFetching || quickActions == null);
    final topBannerHeight = 138.h;
    final bannerAreaHeight = (topBanners.isNotEmpty || showBannerPlaceholder)
        ? topBannerHeight
        : 0.h;

    final middleBannerPage = useState(0);
    final middleBannerController =
        useMemoized(() => PageController(), const []);
    useEffect(() {
      if (middleBanners.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!middleBannerController.hasClients) return;
        final next = (middleBannerPage.value + 1) % middleBanners.length;
        middleBannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [middleBanners.length]);

    final bottomBannerPage = useState(0);
    final bottomBannerController =
        useMemoized(() => PageController(), const []);
    useEffect(() {
      if (bottomBanners.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!bottomBannerController.hasClients) return;
        final next = (bottomBannerPage.value + 1) % bottomBanners.length;
        bottomBannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [bottomBanners.length]);

    final bankingBannerPage = useState(0);
    final bankingBannerController =
        useMemoized(() => PageController(), const []);
    useEffect(() {
      if (bankingInvestmentBanners.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!bankingBannerController.hasClients) return;
        final next =
            (bankingBannerPage.value + 1) % bankingInvestmentBanners.length;
        bankingBannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [bankingInvestmentBanners.length]);

    QuickActionCategory? findCategory(
      List<QuickActionCategory> categories,
      List<String> keywords,
    ) {
      for (final category in categories) {
        final label = category.category.toLowerCase();
        if (keywords.any((keyword) => label.contains(keyword))) {
          return category;
        }
      }
      return categories.isNotEmpty ? categories.first : null;
    }

    Future<void> handleServiceTap(String serviceName) async {
      if (!hasInternet) {
        AppSnackbar.show('No internet connection. Please try again.');
        return;
      }
      if (serviceName == 'Credit Card') {
        if (homeState.isFetchingCreditCards) {
          return;
        }
        await ref
            .read(homeControllerProvider.notifier)
            .fetchCreditCardActions();
        final cards = ref.read(homeControllerProvider).creditCardActions;
        if (cards != null && cards.isNotEmpty) {
          context.push(RouteConstants.creditCardMyCards);
        } else {
          context.push(RouteConstants.creditCardListing);
        }
      } else if (serviceName == 'Mobile Prepaid') {
        context.push(RouteConstants.mobileRecentRecharges);
      } else if (serviceName == 'Tuition Fees' ||
          serviceName == 'Tution Fees' ||
          serviceName == 'School Fees' ||
          serviceName == 'College Fees') {
        context.push(
          RouteConstants.educationFeesAmount,
          extra: serviceName,
        );
      } else {
        context.push(
          RouteConstants.billerListing,
          extra: serviceName,
        );
      }
    }

    final initials = profileState.profile?.initials.isNotEmpty == true
        ? profileState.profile!.initials
        : '';
    final walletBalance = profileState.profile?.walletBalance;
    final isWalletLoading =
        profileState.profile == null && profileState.isFetching;
    final hasWalletError =
        profileState.profile == null && profileState.errorMessage != null;
    final payBillsCategory = quickActions == null
        ? null
        : findCategory(quickActions, ['utilities', 'bills', 'expenses']);
    final educationCategory = quickActions == null
        ? null
        : findCategory(quickActions, ['education', 'lifestyle']);
    final insuranceCategory = quickActions == null
        ? null
        : findCategory(quickActions, ['insurance', 'rent', 'property']);

    final topBannerGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF835C),
        Color(0xFF994F37),
      ],
      stops: [0.0, 0.3807],
    );

    return _HomeScaffoldBody(
      topBannerGradient: topBannerGradient,
      onRefresh: () => Future.wait([
        ref.read(homeControllerProvider.notifier).fetchQuickActions(),
        ref.read(homeControllerProvider.notifier).fetchAllQuickActions(),
        ref.read(spinOptionsControllerProvider.notifier).fetchSpinOptions(),
        ref.read(profileControllerProvider.notifier).fetchProfile(),
      ]),
      quickActions: quickActions,
      homeErrorMessage: homeState.errorMessage,
      isServerUnavailable: homeState.isServerUnavailable,
      bannerAreaHeight: bannerAreaHeight,
      topBanners: topBanners,
      topBannerController: topBannerController,
      topBannerPage: topBannerPage.value,
      onTopBannerPageChanged: (page) => topBannerPage.value = page,
      showBannerPlaceholder: showBannerPlaceholder,
      topBannerHeight: topBannerHeight,
      initials: initials,
      walletBalance: walletBalance,
      isWalletLoading: isWalletLoading,
      hasWalletError: hasWalletError,
      onSearchTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const HomeSearchView(),
          withNavBar: false,
        );
      },
      onReferTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const ReferAndEarnView(),
          withNavBar: false,
        );
      },
      onProfileTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const ProfileView(),
          withNavBar: false,
        );
      },
      onRetryHome: () =>
          ref.read(homeControllerProvider.notifier).fetchQuickActions(),
      onRestart: () => context.go(RouteConstants.splash),
      payBillsServices: payBillsCategory?.services ?? const [],
      educationServices: educationCategory?.services ?? const [],
      insuranceServices: insuranceCategory?.services ?? const [],
      onServiceTap: handleServiceTap,
      onMyBillsTap: () => context.push(RouteConstants.quickActions),
      onExploreUtilitiesTap: () => context.push(RouteConstants.homeSearchView),
      onGoldTap: _showInvestmentComingSoonMessage,
      onSilverTap: _showInvestmentComingSoonMessage,
      bankingInvestmentBanners: bankingInvestmentBanners,
      bankingBannerController: bankingBannerController,
      bankingBannerPage: bankingBannerPage.value,
      onBankingBannerPageChanged: (page) => bankingBannerPage.value = page,
      onBankingBannerTap: () {
        final index = bankingBannerPage.value;
        final banner = index >= 0 && index < bankingInvestmentBanners.length
            ? bankingInvestmentBanners[index]
            : null;
        final redirectUrl = banner?.redirectUrl;
        if (redirectUrl != null && redirectUrl.trim().isNotEmpty) {
          BannerRedirectMapper.handle(context, redirectUrl);
          return;
        }
        _showInvestmentComingSoonMessage();
      },
      middleBanners: middleBanners,
      middleBannerController: middleBannerController,
      middleBannerPage: middleBannerPage.value,
      onMiddleBannerPageChanged: (page) => middleBannerPage.value = page,
      bottomBanners: bottomBanners,
      bottomBannerController: bottomBannerController,
      bottomBannerPage: bottomBannerPage.value,
      onBottomBannerPageChanged: (page) => bottomBannerPage.value = page,
      onMiddleBannerTap: (index) => BannerRedirectMapper.handle(
        context,
        middleBanners[index].redirectUrl,
      ),
      onBottomBannerTap: (index) => BannerRedirectMapper.handle(
        context,
        bottomBanners[index].redirectUrl,
      ),
      onSpinTap: () => context.push(RouteConstants.spinAndWin),
      onFaqTap: () => context.push(RouteConstants.faq),
      isFetchingCreditCards: homeState.isFetchingCreditCards,
    );
  }
}

class _HomeScaffoldBody extends StatelessWidget {
  const _HomeScaffoldBody({
    required this.topBannerGradient,
    required this.onRefresh,
    required this.quickActions,
    required this.homeErrorMessage,
    required this.isServerUnavailable,
    required this.bannerAreaHeight,
    required this.topBanners,
    required this.topBannerController,
    required this.topBannerPage,
    required this.onTopBannerPageChanged,
    required this.showBannerPlaceholder,
    required this.topBannerHeight,
    required this.initials,
    required this.walletBalance,
    required this.isWalletLoading,
    required this.hasWalletError,
    required this.onSearchTap,
    required this.onReferTap,
    required this.onProfileTap,
    required this.onRetryHome,
    required this.onRestart,
    required this.payBillsServices,
    required this.educationServices,
    required this.insuranceServices,
    required this.onServiceTap,
    required this.onMyBillsTap,
    required this.onExploreUtilitiesTap,
    required this.onGoldTap,
    required this.onSilverTap,
    required this.bankingInvestmentBanners,
    required this.bankingBannerController,
    required this.bankingBannerPage,
    required this.onBankingBannerPageChanged,
    required this.onBankingBannerTap,
    required this.middleBanners,
    required this.middleBannerController,
    required this.middleBannerPage,
    required this.onMiddleBannerPageChanged,
    required this.bottomBanners,
    required this.bottomBannerController,
    required this.bottomBannerPage,
    required this.onBottomBannerPageChanged,
    required this.onMiddleBannerTap,
    required this.onBottomBannerTap,
    required this.onSpinTap,
    required this.onFaqTap,
    required this.isFetchingCreditCards,
  });

  final Gradient topBannerGradient;
  final RefreshCallback onRefresh;
  final List<QuickActionCategory>? quickActions;
  final String? homeErrorMessage;
  final bool isServerUnavailable;
  final double bannerAreaHeight;
  final List<BannerModel> topBanners;
  final PageController topBannerController;
  final int topBannerPage;
  final ValueChanged<int> onTopBannerPageChanged;
  final bool showBannerPlaceholder;
  final double topBannerHeight;
  final String initials;
  final double? walletBalance;
  final bool isWalletLoading;
  final bool hasWalletError;
  final VoidCallback onSearchTap;
  final VoidCallback onReferTap;
  final VoidCallback onProfileTap;
  final VoidCallback onRetryHome;
  final VoidCallback onRestart;
  final List<QuickActionService> payBillsServices;
  final List<QuickActionService> educationServices;
  final List<QuickActionService> insuranceServices;
  final Future<void> Function(String serviceName) onServiceTap;
  final VoidCallback onMyBillsTap;
  final VoidCallback onExploreUtilitiesTap;
  final VoidCallback onGoldTap;
  final VoidCallback onSilverTap;
  final List<BannerModel> bankingInvestmentBanners;
  final PageController bankingBannerController;
  final int bankingBannerPage;
  final ValueChanged<int> onBankingBannerPageChanged;
  final VoidCallback onBankingBannerTap;
  final List<BannerModel> middleBanners;
  final PageController middleBannerController;
  final int middleBannerPage;
  final ValueChanged<int> onMiddleBannerPageChanged;
  final List<BannerModel> bottomBanners;
  final PageController bottomBannerController;
  final int bottomBannerPage;
  final ValueChanged<int> onBottomBannerPageChanged;
  final ValueChanged<int> onMiddleBannerTap;
  final ValueChanged<int> onBottomBannerTap;
  final VoidCallback onSpinTap;
  final VoidCallback onFaqTap;
  final bool isFetchingCreditCards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF835C),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFF835C),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 993.h,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: topBannerGradient),
            ),
          ),
          RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0xFFFF835C),
            displacement: 40,
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _HomeTopSliverAppBar(
                  gradient: topBannerGradient,
                  bannerAreaHeight: bannerAreaHeight,
                  topBanners: topBanners,
                  topBannerController: topBannerController,
                  topBannerPage: topBannerPage,
                  onTopBannerPageChanged: onTopBannerPageChanged,
                  showBannerPlaceholder: showBannerPlaceholder,
                  topBannerHeight: topBannerHeight,
                  initials: initials,
                  walletBalance: walletBalance,
                  isWalletLoading: isWalletLoading,
                  hasWalletError: hasWalletError,
                  onSearchTap: onSearchTap,
                  onReferTap: onReferTap,
                  onProfileTap: onProfileTap,
                ),
                if (quickActions == null && homeErrorMessage == null)
                  const HomeShimmer()
                else if (homeErrorMessage != null && quickActions == null)
                  SliverToBoxAdapter(
                    child: _HomeErrorState(
                      isServerUnavailable: isServerUnavailable,
                      onRetry: onRetryHome,
                      onRestart: onRestart,
                    ),
                  )
                else if (quickActions != null)
                  SliverToBoxAdapter(
                    child: _HomeMainSections(
                      payBillsServices: payBillsServices,
                      educationServices: educationServices,
                      insuranceServices: insuranceServices,
                      isFetchingCreditCards: isFetchingCreditCards,
                      onServiceTap: onServiceTap,
                      onMyBillsTap: onMyBillsTap,
                      onExploreUtilitiesTap: onExploreUtilitiesTap,
                      onGoldTap: onGoldTap,
                      onSilverTap: onSilverTap,
                      bankingInvestmentBanners: bankingInvestmentBanners,
                      bankingBannerController: bankingBannerController,
                      bankingBannerPage: bankingBannerPage,
                      onBankingBannerPageChanged: onBankingBannerPageChanged,
                      onBankingBannerTap: onBankingBannerTap,
                      middleBanners: middleBanners,
                      middleBannerController: middleBannerController,
                      middleBannerPage: middleBannerPage,
                      onMiddleBannerPageChanged: onMiddleBannerPageChanged,
                      bottomBanners: bottomBanners,
                      bottomBannerController: bottomBannerController,
                      bottomBannerPage: bottomBannerPage,
                      onBottomBannerPageChanged: onBottomBannerPageChanged,
                      onMiddleBannerTap: onMiddleBannerTap,
                      onBottomBannerTap: onBottomBannerTap,
                      onSpinTap: onSpinTap,
                      onFaqTap: onFaqTap,
                    ),
                  ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _HomeTopSliverAppBar extends StatelessWidget {
  const _HomeTopSliverAppBar({
    required this.gradient,
    required this.bannerAreaHeight,
    required this.topBanners,
    required this.topBannerController,
    required this.topBannerPage,
    required this.onTopBannerPageChanged,
    required this.showBannerPlaceholder,
    required this.topBannerHeight,
    required this.initials,
    required this.walletBalance,
    required this.isWalletLoading,
    required this.hasWalletError,
    required this.onSearchTap,
    required this.onReferTap,
    required this.onProfileTap,
  });

  final Gradient gradient;
  final double bannerAreaHeight;
  final List<BannerModel> topBanners;
  final PageController topBannerController;
  final int topBannerPage;
  final ValueChanged<int> onTopBannerPageChanged;
  final bool showBannerPlaceholder;
  final double topBannerHeight;
  final String initials;
  final double? walletBalance;
  final bool isWalletLoading;
  final bool hasWalletError;
  final VoidCallback onSearchTap;
  final VoidCallback onReferTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      backgroundColor: const Color(0xFFFF835C),
      surfaceTintColor: const Color(0xFFFF835C),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80.h,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFF835C),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      expandedHeight: MediaQuery.of(context).padding.top +
          80.h +
          18.h +
          bannerAreaHeight +
          (topBanners.length > 1 ? 16.h : 0.h),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.none,
        background: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: MediaQuery.of(context).padding.top + 80.h + 12.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.h),
                if (showBannerPlaceholder)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: AppNetworkImage(
                      url: '',
                      width: double.infinity,
                      height: topBannerHeight,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  )
                else if (topBanners.isNotEmpty)
                  SizedBox(
                    height: topBannerHeight,
                    child: PageView.builder(
                      controller: topBannerController,
                      onPageChanged: onTopBannerPageChanged,
                      itemCount: topBanners.length,
                      itemBuilder: (_, index) {
                        final banner = topBanners[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: GestureDetector(
                            onTap: () => BannerRedirectMapper.handle(
                              context,
                              banner.redirectUrl,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: AppNetworkImage(
                                url: banner.image,
                                width: double.infinity,
                                height: topBannerHeight,
                                fit: BoxFit.contain,
                                placeholder: AppNetworkImage(
                                  url: '',
                                  width: double.infinity,
                                  height: topBannerHeight,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 4.h),
                if (topBanners.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      topBanners.length,
                      (index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: _Dot(active: topBannerPage == index),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: _HomeTopBar(
          initials: initials,
          walletBalance: walletBalance,
          isWalletLoading: isWalletLoading,
          hasWalletError: hasWalletError,
          compact: true,
          onSearchTap: onSearchTap,
          onReferTap: onReferTap,
          onProfileTap: onProfileTap,
        ),
      ),
    );
  }
}

class _HomeMainSections extends StatelessWidget {
  const _HomeMainSections({
    required this.payBillsServices,
    required this.educationServices,
    required this.insuranceServices,
    required this.isFetchingCreditCards,
    required this.onServiceTap,
    required this.onMyBillsTap,
    required this.onExploreUtilitiesTap,
    required this.onGoldTap,
    required this.onSilverTap,
    required this.bankingInvestmentBanners,
    required this.bankingBannerController,
    required this.bankingBannerPage,
    required this.onBankingBannerPageChanged,
    required this.onBankingBannerTap,
    required this.middleBanners,
    required this.middleBannerController,
    required this.middleBannerPage,
    required this.onMiddleBannerPageChanged,
    required this.bottomBanners,
    required this.bottomBannerController,
    required this.bottomBannerPage,
    required this.onBottomBannerPageChanged,
    required this.onMiddleBannerTap,
    required this.onBottomBannerTap,
    required this.onSpinTap,
    required this.onFaqTap,
  });

  final List<QuickActionService> payBillsServices;
  final List<QuickActionService> educationServices;
  final List<QuickActionService> insuranceServices;
  final bool isFetchingCreditCards;
  final Future<void> Function(String serviceName) onServiceTap;
  final VoidCallback onMyBillsTap;
  final VoidCallback onExploreUtilitiesTap;
  final VoidCallback onGoldTap;
  final VoidCallback onSilverTap;
  final List<BannerModel> bankingInvestmentBanners;
  final PageController bankingBannerController;
  final int bankingBannerPage;
  final ValueChanged<int> onBankingBannerPageChanged;
  final VoidCallback onBankingBannerTap;
  final List<BannerModel> middleBanners;
  final PageController middleBannerController;
  final int middleBannerPage;
  final ValueChanged<int> onMiddleBannerPageChanged;
  final List<BannerModel> bottomBanners;
  final PageController bottomBannerController;
  final int bottomBannerPage;
  final ValueChanged<int> onBottomBannerPageChanged;
  final ValueChanged<int> onMiddleBannerTap;
  final ValueChanged<int> onBottomBannerTap;
  final VoidCallback onSpinTap;
  final VoidCallback onFaqTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Pay Bills & Expenses',
                    actionLabel: 'My Bills',
                    onAction: onMyBillsTap,
                  ),
                  SizedBox(height: 14.h),
                  _PayBillsCard(
                    services: payBillsServices,
                    onTap: onServiceTap,
                    onExploreTap: onExploreUtilitiesTap,
                    isCreditCardLoading: isFetchingCreditCards,
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: 393.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  const _SectionHeader(title: 'Banking & Investments'),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 57.5.h,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 188.w,
                          child: GestureDetector(
                            onTap: onGoldTap,
                            child: _InvestmentTile(
                              label: 'Buy Gold',
                              iconAsset: FileConstants.digitalGoldGif,
                              arrowAsset: FileConstants.goldArrow,
                              borderColor: const Color(0xFFD1A903),
                              textColor: const Color(0xFF8B6B12),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        SizedBox(
                          width: 188.w,
                          child: GestureDetector(
                            onTap: onSilverTap,
                            child: _InvestmentTile(
                              label: 'Buy Silver',
                              iconAsset: FileConstants.digitalSilverGif,
                              arrowAsset: FileConstants.silverArrow,
                              borderColor: const Color(0xFFDDDDDD),
                              textColor: const Color(0xFF6B6B6B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (bankingInvestmentBanners.isNotEmpty) ...[
              SizedBox(height: 18.h),
              Transform.translate(
                offset: Offset(-1.w, 0),
                child: InkWell(
                  onTap: onBankingBannerTap,
                  child: SizedBox(
                    height: 73.h,
                    width: 442.w,
                    child: PageView.builder(
                      controller: bankingBannerController,
                      onPageChanged: onBankingBannerPageChanged,
                      itemCount: bankingInvestmentBanners.length,
                      itemBuilder: (_, index) => AppNetworkImage(
                        url: bankingInvestmentBanners[index].image,
                        width: 442.w,
                        height: 73.h,
                        fit: BoxFit.cover,
                        placeholder: AppNetworkImage(
                          url: '',
                          width: 442.w,
                          height: 73.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Education & Lifestyle'),
                  SizedBox(height: 12.h),
                  _CurvedIconGrid(
                    services: educationServices,
                    onTap: onServiceTap,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (middleBanners.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Center(
                      child: SizedBox(
                        width: 393.w,
                        height: 145.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: PageView.builder(
                            controller: middleBannerController,
                            onPageChanged: onMiddleBannerPageChanged,
                            itemCount: middleBanners.length,
                            itemBuilder: (_, index) => GestureDetector(
                              onTap: () => onMiddleBannerTap(index),
                              child: AppNetworkImage(
                                url: middleBanners[index].image,
                                width: 393.w,
                                height: 145.h,
                                fit: BoxFit.cover,
                                placeholder: AppNetworkImage(
                                  url: '',
                                  width: 393.w,
                                  height: 145.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (middleBanners.length > 1) ...[
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          middleBanners.length,
                          (index) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: _Dot(active: middleBannerPage == index),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Insurance & Rent',
                    actionLabel: 'View All',
                    onAction: onMyBillsTap,
                  ),
                  SizedBox(height: 12.h),
                  _CurvedIconGrid(
                    services: _insuranceServicesInDisplayOrder(
                      insuranceServices,
                    ),
                    onTap: onServiceTap,
                    labelBuilder: (service) {
                      final name = service.name.trim();
                      final lower = name.toLowerCase();
                      if (lower.contains('insurance')) return name;
                      if (lower == 'general' ||
                          lower == 'health' ||
                          lower == 'life') {
                        return '$name Insurance';
                      }
                      return name;
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            Container(
              width: 440.w,
              height: 77.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFF9D7E),
                    Color(0xFF003072),
                  ],
                ),
              ),
              child: _ImageBanner(
                asset: FileConstants.homeBanner9,
                height: 77.h,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _MiniActionCard(
                        title: 'Gift card',
                        subtitle: 'Gift your friends',
                        asset: FileConstants.giftIcon,
                        iconWidth: 22,
                        iconHeight: 26,
                        backgroundColor: const Color(0xFFFFF0EC),
                        gradientBorder: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFFF9776),
                            Color(0xFFDD5428),
                          ],
                        ),
                        arrowColor: const Color(0xFFDD5428),
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w),
                      _MiniActionCard(
                        title: 'Spin & Win',
                        subtitle: 'Spin and win',
                        asset: FileConstants.spinIcon,
                        backgroundColor: const Color(0x050554BD),
                        borderColor: const Color(0x33002352),
                        arrowColor: const Color(0xFF002352),
                        onTap: onSpinTap,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _SupportTile(
                    title: 'FAQ & Support',
                    onTap: onFaqTap,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            if (bottomBanners.isNotEmpty)
              SizedBox(
                width: 440.w,
                height: 180.h,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: bottomBannerController,
                      physics: bottomBanners.length > 1
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      onPageChanged: onBottomBannerPageChanged,
                      itemCount: bottomBanners.length,
                      itemBuilder: (_, index) => GestureDetector(
                        onTap: () => onBottomBannerTap(index),
                        child: AppNetworkImage(
                          url: bottomBanners[index].image,
                          width: 440.w,
                          height: 180.h,
                          fit: BoxFit.cover,
                          placeholder: AppNetworkImage(
                            url: '',
                            width: 440.w,
                            height: 180.h,
                          ),
                        ),
                      ),
                    ),
                    if (bottomBanners.length > 1)
                      Positioned(
                        left: 24.w,
                        bottom: 16.h,
                        child: Row(
                          children: List.generate(
                            bottomBanners.length,
                            (index) => Padding(
                              padding: EdgeInsets.only(right: 5.w),
                              child: _Dot(
                                active: bottomBannerPage == index,
                                onBanner: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Container(
              decoration: const BoxDecoration(color: Color(0XFFFDFDFD)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Row(
                  children: [
                    Text(
                      'Powered By',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(width: 6.w),
                    Image.asset(
                      FileConstants.bharatConnectColor,
                      height: 22.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TemporaryBlockFlowType? _resolveTemporaryBlockFlow(ProfileModel? profile) {
  if (TemporaryBlockDebugConfig.enabled) {
    return TemporaryBlockDebugConfig.flowType;
  }
  return null;
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({
    this.isServerUnavailable = false,
    required this.onRetry,
    required this.onRestart,
  });

  final bool isServerUnavailable;
  final VoidCallback onRetry;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    if (isServerUnavailable) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          children: [
            Text(
              'Opps!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1ED),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Image.asset(
                FileConstants.serverDown,
                height: 160.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'Something Went Wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We’re currently facing a temporary server issue.\nYour account and funds remain safe and secure.\nPlease try again after a few minutes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.8),
                    height: 1.55,
                  ),
            ),
            SizedBox(height: 18.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5DE),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                'Error Code: ERU-SRV-503',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
      child: Column(
        children: [
          Image.asset(
            FileConstants.somethingWentWrong,
            width: 170.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),
          Text(
            'Something Went Wrong',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'We’re facing a temporary issue loading your data. Please try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  height: 1.4,
                ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  onPressed: onRetry,
                  label: 'Retry',
                  uppercaseLabel: false,
                  height: 35.h,
                  isBorder: true,
                  backgroundColor: Colors.white,
                  borderColor: AppColors.primary,
                  labelColor: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: onRestart,
                  label: 'Restart',
                  uppercaseLabel: false,
                  height: 35.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeReminderDialog extends StatelessWidget {
  const _HomeReminderDialog({
    required this.data,
    this.onPrimaryTap,
  });

  final BillReminderItem data;
  final VoidCallback? onPrimaryTap;

  void _close(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFF7A2E11),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _billReminderTitle(data.paymentType),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              _billReminderDueText(data),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5.sp,
                  ),
            ),
            SizedBox(height: 14.h),
            Container(
              width: 82.w,
              height: 82.w,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: data.billerIcon.trim().isNotEmpty
                  ? ClipOval(
                      child: AppNetworkImage(
                        url: data.billerIcon,
                        fit: BoxFit.contain,
                        showShimmer: false,
                      ),
                    )
                  : Image.asset(
                      FileConstants.bharatConnectColor,
                      fit: BoxFit.contain,
                    ),
            ),
            SizedBox(height: 12.h),
            Text(
              _billReminderIdentifier(data),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF05A28),
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                  ),
            ),
            SizedBox(height: 6.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                children: [
                  const TextSpan(text: 'Amount Due: '),
                  TextSpan(
                    text: _formatReminderAmount(data.lastBillAmount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                _billReminderMessage(data),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.78),
                      fontSize: 12.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () => _close(context),
                    label: 'Later',
                    uppercaseLabel: false,
                    height: 40.h,
                    isBorder: true,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFF05A28),
                    labelColor: const Color(0xFFF05A28),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: onPrimaryTap,
                    label: 'Pay Now',
                    uppercaseLabel: false,
                    height: 40.h,
                    backgroundColor: const Color(0xFFF05A28),
                    labelColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _billReminderTitle(String paymentType) {
  final trimmed = paymentType.trim();
  if (trimmed.isEmpty) return 'Reminder';
  if (trimmed.toLowerCase() == 'recharge') return 'Recharge Reminder';
  return '$trimmed Reminder';
}

String _billReminderMessage(BillReminderItem data) {
  final description = data.description?.trim() ?? '';
  if (description.isNotEmpty) return description;
  return 'Pay before the due date to avoid late payment charges.';
}

String _billReminderDueText(BillReminderItem data) {
  final dueDate = _formatReminderDate(data.dueDate);
  final daysRemaining = data.daysRemaining;
  if (daysRemaining > 0 && dueDate.isNotEmpty) {
    final label = daysRemaining == 1 ? 'Day' : 'Days';
    return 'Due in $daysRemaining $label : $dueDate';
  }
  final note = data.note.trim();
  if (note.isNotEmpty && dueDate.isNotEmpty) {
    return '$note : $dueDate';
  }
  if (dueDate.isNotEmpty) return dueDate;
  return note;
}

String _billReminderIdentifier(BillReminderItem data) {
  final paymentType = data.paymentType.trim().toLowerCase();
  final masked = data.maskedIdentifier.trim();
  final mobile = data.customerMobile.trim();
  if (paymentType.contains('mobile') || paymentType.contains('recharge')) {
    if (mobile.isNotEmpty) return mobile;
    if (masked.isNotEmpty) return masked;
    return data.billerId.trim();
  }
  if (masked.isNotEmpty) return masked;
  if (mobile.isNotEmpty) return mobile;
  return data.billerId.trim();
}

String _resolveReminderPrefillValue(BillReminderItem data) {
  final paymentType = data.paymentType.trim().toLowerCase();
  final masked = data.maskedIdentifier.trim();
  final mobile = data.customerMobile.trim();
  if (paymentType.contains('credit')) {
    return mobile;
  }
  if (paymentType.contains('mobile') || paymentType.contains('recharge')) {
    if (mobile.isNotEmpty) return mobile;
    return masked;
  }
  if (masked.isNotEmpty) return masked;
  return mobile;
}

String _formatReminderAmount(double amount) {
  final absolute = amount.abs();
  final isWhole = absolute == absolute.truncateToDouble();
  final value =
      isWhole ? absolute.toStringAsFixed(0) : absolute.toStringAsFixed(2);
  return '₹$value';
}

String _formatReminderDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
}
