// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../models/support_latest_transaction.dart';
import '../models/transaction_history_entry.dart';
import '../utils/receipt_actions.dart';
import 'create_support_ticket_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    this.entry,
    this.doneLabel = 'Done',
    this.onDone,
    this.onBack,
    this.navigateHomeOnExit = false,
  });

  final TransactionHistoryEntry? entry;
  final String doneLabel;
  final VoidCallback? onDone;
  final VoidCallback? onBack;
  final bool navigateHomeOnExit;

  @override
  Widget build(BuildContext context) {
    final tx = entry ??
        const TransactionHistoryEntry(
          paymentStatus: '',
          paymentType: '',
          billerName: '',
          maskedIdentifier: '',
          amount: '',
          platformFees: '',
          totalAmountCharged: '',
          customerMobile: '',
          iconUrl: '',
          pgTransactionId: '',
          ecoinsTransactionId: '',
          transactionId: '',
          bankReferenceId: '',
          referenceId: '',
          transactionTime: '',
          method: '',
          methodIcon: '',
          paymentMode: '',
          vpa: '',
          rrn: '',
          customerParams: [],
          amountBreakdown: {},
        );

    final status = tx.paymentStatus.trim().toUpperCase();
    final paymentMethod =
        tx.method.trim().isNotEmpty ? tx.method.trim() : 'UPI/GPay';
    final totalAmount = tx.totalAmountCharged.trim().isNotEmpty
        ? tx.totalAmountCharged
        : tx.amount;
    final statusMeta = _statusMeta(
      status,
      refundAmount: _formatAmount(totalAmount),
      paymentType: tx.paymentType.trim(),
    );
    final txnId = tx.transactionId.trim();
    final pgTxnId = tx.pgTransactionId.trim();
    final walletTxnId = tx.ecoinsTransactionId.trim();
    final bankRefId = tx.bankReferenceId.trim();
    final refId = tx.referenceId.trim();
    final receiptId = _resolveReceiptTransactionId(refId: refId, txnId: txnId);
    final supportTransaction = SupportLatestTransaction(
      id: refId.isNotEmpty ? refId : txnId,
      paymentType: tx.paymentType.trim(),
      billerName: tx.billerName.trim(),
      amount: totalAmount.trim(),
      status: tx.paymentStatus.trim(),
      date: tx.transactionTime.trim(),
      type: _resolveSupportTransactionType(tx),
      transactionId: txnId,
    );
    final resolvedParams = _resolveHeaderParams(tx);
    final primaryParam = resolvedParams.first;
    final secondaryParam =
        resolvedParams.length > 1 ? resolvedParams[1] : resolvedParams.first;
    final breakdownRows = tx.amountBreakdown.isNotEmpty
        ? tx.amountBreakdown.entries.map((entry) {
            final isTotal = entry.key.trim().toLowerCase() == 'total';
            return _DetailValueRow(
              label: entry.key,
              value: _formatBreakdownValue(entry.value),
              emphasize: isTotal,
            );
          }).toList(growable: false)
        : <_DetailValueRow>[
            _DetailValueRow(
              label: tx.paymentType.trim().toLowerCase().contains('recharge')
                  ? 'Recharge Amount'
                  : 'Bill Amount',
              value: _formatAmount(tx.amount),
            ),
            if (_hasAmount(tx.platformFees))
              _DetailValueRow(
                label: 'Platform Fees',
                value: _formatAmount(tx.platformFees),
              ),
            const _DetailValueRow(label: 'eCoins', value: '- ₹15'),
            _DetailValueRow(
              label: 'Total',
              value: _formatAmount(totalAmount),
              emphasize: true,
            ),
          ];
    final detailRows = <_DetailValueRow>[
      _DetailValueRow(label: 'Amount', value: _formatAmount(totalAmount)),
      _DetailValueRow(label: 'Payment Method', value: paymentMethod),
      _DetailValueRow(
        label: 'Transaction ID',
        value: pgTxnId.isNotEmpty
            ? pgTxnId
            : (walletTxnId.isNotEmpty ? walletTxnId : txnId),
        copyable: true,
      ),
      if (refId.isNotEmpty)
        _DetailValueRow(
          label: 'Reference ID',
          value: refId,
          copyable: true,
        ),
      if (bankRefId.isNotEmpty)
        _DetailValueRow(
          label: 'Bank Reference ID',
          value: bankRefId,
          copyable: true,
        ),
    ];

    Future<void> handleExitToHome() async {
      final navigator = Navigator.of(context, rootNavigator: true);
      navigator.popUntil((route) => route.isFirst);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rootContext = navigatorKey.currentContext;
        if (rootContext != null && rootContext.mounted) {
          rootContext.go(RouteConstants.home);
        }
      });
    }

    final effectiveOnDone = navigateHomeOnExit
        ? () {
            handleExitToHome();
          }
        : onDone;
    final effectiveOnBack = navigateHomeOnExit
        ? () {
            handleExitToHome();
          }
        : onBack;

    final screen = Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSuccess = status == 'SUCCESS';
          final hasStatusMessage = statusMeta.message.isNotEmpty;
          
          final headerTop = isSuccess ? 111.h : 101.h; 
          final headerHorizontalPadding = 24.w;
          final sectionGap = 16.h;
          final titleToDateGap = isSuccess ? 12.h : 8.h;
          final headerWidth = 393.w;
          
          final titleStyle = isSuccess 
            ? GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 24.sp,
              )
            : Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ) ??
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              );
          final dateStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                  ) ??
              TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12.sp,
              );
          final messageStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    height: 1.5,
                    fontSize: 11.sp,
                  ) ??
              TextStyle(
                color: Colors.white,
                height: 1.5,
                fontSize: 11.sp,
              );
          
          final titleHeight = _measureTextHeight(
            context,
            text: statusMeta.title,
            style: titleStyle,
            maxWidth: isSuccess ? 287.w : headerWidth,
          );
          final dateHeight = _measureTextHeight(
            context,
            text: _formatHeaderDate(tx.transactionTime),
            style: dateStyle,
            maxWidth: headerWidth,
          );
          
          // SUCCESS Specific elements heights
          final amountPillHeight = isSuccess ? 40.h : 0.0;
          
          final headerContentHeight = isSuccess 
              ? (64.w + 20.h + titleHeight + 16.h + amountPillHeight + titleToDateGap + dateHeight)
              : (64.w + sectionGap + titleHeight + titleToDateGap + dateHeight + (hasStatusMessage ? sectionGap + 88.h : 0.0));
          
          final cardTop = isSuccess ? 419.h : (headerTop + headerContentHeight + 16.h);
          
          const minHeaderHeight = 360.0;
          final computedHeaderHeight = isSuccess ? 380.h : (cardTop + 40.h);
          final headerHeight = computedHeaderHeight < minHeaderHeight.h
              ? minHeaderHeight.h
              : computedHeaderHeight;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (isSuccess)
                // Ellipse 30 Design for Success Only
                Positioned(
                  top: -369.h,
                  left: -199.w,
                  child: Container(
                    width: 838.w,
                    height: 756.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(419.w, 378.h),
                      ),
                      gradient: LinearGradient(
                        colors: statusMeta.gradient,
                        stops: const [0.0, 0.3446, 0.9055, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                )
              else
                // Original Header for other states
                Column(
                  children: [
                    Container(
                      height: headerHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: statusMeta.gradient,
                          stops: const [0.0, 0.3446, 0.9055, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ],
                ),
              Positioned(
                left: 12.w,
                top: MediaQuery.of(context).padding.top + 8.h,
                child: IconButton(
                  onPressed: effectiveOnBack ?? () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: headerHorizontalPadding,
                right: headerHorizontalPadding,
                top: headerTop,
                child: Column(
                  children: [
                    Image.asset(
                      statusMeta.iconAsset,
                      width: 64.w,
                      height: 64.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isSuccess ? 20.h : 16.h),
                    SizedBox(
                      width: isSuccess ? 287.w : headerWidth,
                      child: Text(
                        statusMeta.title,
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                    ),
                    if (isSuccess) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _formatAmount(totalAmount),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF0C602D),
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                              ),
                        ),
                      ),
                    ],
                    SizedBox(height: titleToDateGap),
                    Text(
                      _formatHeaderDate(tx.transactionTime),
                      textAlign: TextAlign.center,
                      style: dateStyle,
                    ),
                    if (!isSuccess && statusMeta.message.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _StatusMessageBox(
                        statusMeta: statusMeta,
                        messageStyle: messageStyle,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 24.w,
                right: 23.w, // designSize is 440, so 440 - 24 - 393 = 23
                top: cardTop,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 18.h),
                          child: Column(
                            children: [
                              _TransactionResultCard(
                                primaryParam: primaryParam,
                                secondaryParam: secondaryParam,
                                detailRows: detailRows,
                                breakdownRows: breakdownRows,
                                isSuccess: isSuccess,
                              ),
                              SizedBox(height: isSuccess ? 40.h : 20.h),
                              if (!isSuccess) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _ResultActionButton(
                                      icon: Icons.headset_mic_outlined,
                                      label: 'Contact Support',
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CreateSupportTicketScreen(
                                              transaction: supportTransaction,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _ResultActionButton(
                                      icon: Icons.share_outlined,
                                      label: 'Share Receipt',
                                      onTap: () =>
                                          ReceiptActions.handleReceiptAction(
                                        context,
                                        transactionId: receiptId,
                                        action: ReceiptAction.share,
                                      ),
                                    ),
                                    _ResultActionButton(
                                      icon: Icons.receipt_long_outlined,
                                      label: 'Download Receipt',
                                      onTap: () =>
                                          ReceiptActions.handleReceiptAction(
                                        context,
                                        transactionId: receiptId,
                                        action: ReceiptAction.download,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: CustomElevatedButton(
                          onPressed: effectiveOnDone ?? () => context.pop(),
                          label: doneLabel,
                          uppercaseLabel: false,
                          showArrow: false,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 58.w,
                            height: 25.h,
                            child: Text(
                              'powered by',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 2.5, // To match 25px line-height for 10px font
                                  ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Image.asset(
                            FileConstants.bharatConnectColor,
                            width: 52.w,
                            height: 24.h,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (effectiveOnBack == null) {
      return screen;
    }

    return WillPopScope(
      onWillPop: () async {
        effectiveOnBack.call();
        return false;
      },
      child: screen,
    );
  }
}

List<TransactionCustomerParam> _resolveHeaderParams(
    TransactionHistoryEntry tx) {
  final explicit = tx.customerParams
      .where(
        (item) => item.label.trim().isNotEmpty && item.value.trim().isNotEmpty,
      )
      .toList(growable: false);
  if (explicit.isNotEmpty) return explicit;

  final paymentType = tx.paymentType.trim().toLowerCase();
  final billerName = tx.billerName.trim();
  final customerMobile = tx.customerMobile.trim();
  final maskedIdentifier = tx.maskedIdentifier.trim();

  if (paymentType.contains('credit')) {
    final mobileValue = customerMobile.isNotEmpty
        ? customerMobile
        : (maskedIdentifier.isNotEmpty ? maskedIdentifier : billerName);
    final digits = maskedIdentifier.replaceAll(RegExp(r'\D'), '');
    final last4 =
        digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    return [
      TransactionCustomerParam(
        label: 'Registered Mobile Number',
        value: mobileValue.isNotEmpty ? mobileValue : billerName,
      ),
      TransactionCustomerParam(
        label: 'Last 4 digits of Credit Card Number',
        value: last4.isNotEmpty ? last4 : billerName,
      ),
    ];
  }

  final secondaryLabel =
      paymentType.isNotEmpty ? tx.paymentType.trim() : 'Details';
  final secondaryValue =
      maskedIdentifier.isNotEmpty ? maskedIdentifier : customerMobile;

  return [
    TransactionCustomerParam(
      label: 'Payment to',
      value: billerName.isNotEmpty ? billerName : 'Transaction',
    ),
    TransactionCustomerParam(
      label: secondaryLabel,
      value: secondaryValue.isNotEmpty
          ? secondaryValue
          : (billerName.isNotEmpty ? billerName : 'Transaction'),
    ),
  ];
}

class _TransactionResultCard extends StatelessWidget {
  const _TransactionResultCard({
    required this.primaryParam,
    required this.secondaryParam,
    required this.detailRows,
    required this.breakdownRows,
    this.isSuccess = false,
  });

  final TransactionCustomerParam primaryParam;
  final TransactionCustomerParam secondaryParam;
  final List<_DetailValueRow> detailRows;
  final List<_DetailValueRow> breakdownRows;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSuccess ? 392.w : 393.w,
      height: isSuccess ? 340.h : null, // Reduced height as requested
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFEFEFEF) : Colors.white,
        borderRadius: BorderRadius.circular(isSuccess ? 20.r : 12.r),
        boxShadow: isSuccess 
            ? null 
            : [
                BoxShadow(
                  color: const Color(0x1AC2C2C2),
                  blurRadius: 24.r,
                  offset: Offset(0, 11.h),
                ),
                BoxShadow(
                  color: const Color(0x17C2C2C2),
                  blurRadius: 43.r,
                  offset: Offset(0, 43.h),
                ),
                BoxShadow(
                  color: const Color(0x0DC2C2C2),
                  blurRadius: 58.r,
                  offset: Offset(0, 97.h),
                ),
                BoxShadow(
                  color: const Color(0x03C2C2C2),
                  blurRadius: 69.r,
                  offset: Offset(0, 173.h),
                ),
              ],
      ),
      child: isSuccess 
        ? const SizedBox.shrink() 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CardHeading(
                      label: primaryParam.label,
                      value: primaryParam.value,
                      alignEnd: false,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _CardHeading(
                      label: secondaryParam.label,
                      value: secondaryParam.value,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Divider(color: AppColors.lightBorder.withOpacity(0.5), height: 1.h),
              SizedBox(height: 8.h),
              ...detailRows.map(
                (row) => _CardDetailRow(
                  row: row,
                  fullWidthValueAlignment: true,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Amount Breakdown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                    ),
              ),
              SizedBox(height: 4.h),
              ...breakdownRows.map(
                (row) => _CardDetailRow(
                  row: row,
                  fullWidthValueAlignment: true,
                  showTopDivider: row.emphasize,
                  horizontalInset: row.emphasize ? 0 : null,
                ),
              ),
            ],
          ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.6),
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
        ),
      ],
    );
  }
}

class _CardDetailRow extends StatelessWidget {
  const _CardDetailRow({
    required this.row,
    this.fullWidthValueAlignment = false,
    this.showTopDivider = false,
    this.horizontalInset,
  });

  final _DetailValueRow row;
  final bool fullWidthValueAlignment;
  final bool showTopDivider;
  final double? horizontalInset;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontWeight:
                        row.emphasize ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 14.sp,
                    height: 1.0,
                  ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                    row.value,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontWeight:
                              row.emphasize ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 14.sp,
                          height: 1.0,
                        ),
                  ),
                ),
                if (row.copyable) ...[
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: row.value));
                      AppSnackbar.show('Copied to clipboard');
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    final rowWidget = showTopDivider
        ? Column(
            children: [
              Divider(
                color: AppColors.lightBorder.withOpacity(0.75),
                height: 12.h,
                thickness: 1,
              ),
              content,
            ],
          )
        : content;

    if (horizontalInset == null) return rowWidget;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset!),
      child: rowWidget,
    );
  }
}

class _ResultActionButton extends StatelessWidget {
  const _ResultActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: 120.w,
        height: 83.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.w, // Standard branded icon size
              height: 52.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFDEEE7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD65228),
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontSize: 10.sp, // Reduced font size to match design
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessageBox extends StatelessWidget {
  const _StatusMessageBox({
    required this.statusMeta,
    required this.messageStyle,
  });

  final _StatusMeta statusMeta;
  final TextStyle messageStyle;

  @override
  Widget build(BuildContext context) {
    final hasTitle = statusMeta.messageTitle.isNotEmpty;
    // Restoring the "perfect" sizing: 80h for Pending, 88h for Refund/Failed
    final boxHeight = hasTitle ? 88.h : 80.h;
    
    return Container(
      width: 393.w,
      height: boxHeight,
      padding: EdgeInsets.only(
        top: 10.h,
        right: 16.w,
        bottom: 10.h,
        left: 16.w,
      ),
      decoration: BoxDecoration(
        color: statusMeta.messageBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasTitle) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: statusMeta.messageIndicatorGradient.isNotEmpty
                        ? LinearGradient(
                            colors: statusMeta.messageIndicatorGradient,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: statusMeta.messageIndicatorGradient.isEmpty
                        ? Colors.white
                        : null,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    statusMeta.messageTitle,
                    textAlign: TextAlign.center,
                    style: messageStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
          ],
          Text(
            statusMeta.message,
            textAlign: TextAlign.center,
            style: messageStyle.copyWith(
              fontSize: 11.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailValueRow {
  const _DetailValueRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool copyable;
  final bool emphasize;
}

double _measureTextHeight(
  BuildContext context, {
  required String text,
  required TextStyle style,
  required double maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: maxWidth);
  return painter.size.height;
}

class _StatusMeta {
  const _StatusMeta({
    required this.title,
    required this.iconAsset,
    required this.gradient,
    this.message = '',
    this.messageTitle = '',
    this.messageIndicatorGradient = const [],
    this.messageBackgroundColor = const Color(0xFF09301A),
  });

  final String title;
  final String iconAsset;
  final List<Color> gradient;
  final String message;
  final String messageTitle;
  final List<Color> messageIndicatorGradient;
  final Color messageBackgroundColor;
}

_StatusMeta _statusMeta(
  String status, {
  required String refundAmount,
  required String paymentType,
}) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return _StatusMeta(
        title: 'Thank You for $paymentType Payment',
        iconAsset: FileConstants.successIcon,
        gradient: const [
          Color(0xFF004C1E),
          Color(0xFF149248),
          Color(0xFF136E3C),
          Color(0xFF007340),
        ],
      );
    case 'PENDING':
    case 'PROCESSING':
      return _StatusMeta(
        title: 'Transaction Pending',
        iconAsset: FileConstants.pendingIcon,
        gradient: const [
          Color(0xFFB08900),
          Color(0xFFB08900),
          Color(0xFF6B4E00),
          Color(0xFF5D3A00),
        ],
        message:
            'Your transaction is currently pending. Please wait a few moments while we confirm your payment status. If the amount has been deducted, it will be updated shortly.',
        messageBackgroundColor: const Color(0x80000000),
      );
    case 'FAILED':
    case 'REFUND_PENDING':
      return _StatusMeta(
        title: 'Transaction Failed',
        iconAsset: FileConstants.failedIcon,
        gradient: const [
          Color(0xFFB3261E),
          Color(0xFF8B1919),
          Color(0xFF7D1A15),
          Color(0xFF6D120E),
        ],
        messageTitle: 'Refund Initiated',
        message:
            'Your transaction failed. A refund of $refundAmount has been initiated and is expected to be credited within 3–5 business days.',
        messageIndicatorGradient: const [
          Color(0xFFFB8A67),
          Color(0xFFDD5428),
        ],
        messageBackgroundColor: const Color(0x80000000),
      );
    case 'REFUNDED':
      return _StatusMeta(
        title: 'Transaction Failed',
        iconAsset: FileConstants.failedIcon,
        gradient: const [
          Color(0xFFB3261E),
          Color(0xFF8B1919),
          Color(0xFF7D1A15),
          Color(0xFF6D120E),
        ],
        messageTitle: 'Refund Completed',
        message:
            '$refundAmount has been successfully refunded to your original payment method. No further action is required.',
        messageIndicatorGradient: const [
          Color(0xFF60EB97),
          Color(0xFF058337),
        ],
        messageBackgroundColor: const Color(0x80000000),
      );
    default:
      return _StatusMeta(
        title: 'Transaction Details',
        iconAsset: FileConstants.successIcon,
        gradient: const [
          Color(0xFF004C1E),
          Color(0xFF149248),
          Color(0xFF136E3C),
          Color(0xFF007340),
        ],
      );
  }
}

String _resolveReceiptTransactionId({
  required String refId,
  required String txnId,
}) {
  return ReceiptActions.resolveReceiptTransactionId(refId: refId, txnId: txnId);
}

String _resolveSupportTransactionType(TransactionHistoryEntry tx) {
  final paymentType = tx.paymentType.trim().toLowerCase();
  if (paymentType.contains('education')) return 'EDUCATION';
  if (paymentType.contains('gold') ||
      paymentType.contains('silver') ||
      paymentType.contains('metal')) {
    return 'METAL';
  }
  return 'BBPS';
}

bool _hasAmount(String raw) => raw.trim().isNotEmpty;

String _formatAmount(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.startsWith('₹') ? trimmed : '₹$trimmed';
}

String _formatBreakdownValue(dynamic raw) {
  if (raw == null) return '';
  if (raw is num) {
    final value =
        raw % 1 == 0 ? raw.toStringAsFixed(0) : raw.toStringAsFixed(2);
    return '₹$value';
  }
  final trimmed = raw.toString().trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('₹')) return trimmed;
  final parsed = double.tryParse(trimmed.replaceAll(',', ''));
  if (parsed == null) return trimmed;
  final value =
      parsed % 1 == 0 ? parsed.toStringAsFixed(0) : parsed.toStringAsFixed(2);
  return '₹$value';
}

String _formatHeaderDate(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) return value;
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final day = parsed.day.toString();
  final month = months[parsed.month - 1];
  final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final ampm = parsed.hour >= 12 ? 'pm' : 'am';
  return '$day $month ${parsed.year}, $hour:$minute$ampm';
}
