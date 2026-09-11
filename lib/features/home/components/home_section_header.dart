import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.onTap,
    this.padding,
    this.titleStyle,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle ??
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 16.sp,
                    ),
          ),
        ),
        if (actionLabel != null) ...[
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
            ),
          ),
        ],
        if (trailing != null) trailing!,
      ],
    );

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: row,
              ),
            ),
    );
  }
}
