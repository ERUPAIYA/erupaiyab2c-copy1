// ignore_for_file: deprecated_member_use

import 'package:e_rupaiya/constants/file_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class SearchTextfield extends StatelessWidget {
  const SearchTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.onChange,
    this.onFilterPressed,
    this.height,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.prefixIconSize,
    this.prefixIconPadding,
    this.hintFontSize,
  });

  final String hintText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChange;
  final VoidCallback? onFilterPressed;
  final double? height;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final double? prefixIconSize;
  final EdgeInsetsGeometry? prefixIconPadding;
  final double? hintFontSize;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 12.r;
    final borderSide = BorderSide(
      color: borderColor ?? AppColors.lightBorder,
      width: 1,
    );
    final focusedSide = BorderSide(
      color: focusedBorderColor ?? AppColors.primary,
      width: 1,
    );
    final iconSize = prefixIconSize ?? 20.w;
    final iconPadding = prefixIconPadding ?? EdgeInsets.all(12.w);

    Widget field = ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChange,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            isDense: height != null,
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.4),
              fontWeight: FontWeight.w400,
              fontSize: hintFontSize ?? 12.sp,
            ),
            prefixIcon: prefixIcon ??
                Padding(
                  padding: iconPadding,
                  child: Image.asset(
                    FileConstants.orangeSearch,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
            prefixIconConstraints: height == null
                ? null
                : BoxConstraints(
                    minWidth: iconSize +
                        iconPadding.resolve(TextDirection.ltr).horizontal,
                    minHeight: iconSize,
                    maxHeight: height!,
                  ),
            suffixIcon: onFilterPressed == null
                ? (value.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          controller.clear();
                          onChange?.call('');
                        },
                      )
                    : null)
                : IconButton(
                    onPressed: onFilterPressed,
                    icon: Icon(
                      Icons.filter_list,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
            filled: true,
            fillColor: fillColor ?? Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: borderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: borderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: focusedSide,
            ),
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
          ),
        );
      },
    );

    if (height == null) return field;
    return SizedBox(height: height, child: field);
  }
}
