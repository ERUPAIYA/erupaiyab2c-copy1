import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:e_rupaiya/features/educationFees/controllers/education_fees_controller.dart';
import 'package:e_rupaiya/features/educationFees/models/education_fees_responses.dart';
import 'package:e_rupaiya/features/educationFees/repositories/education_fees_repository.dart';
import 'package:e_rupaiya/features/profile/models/transaction_history_entry.dart';
import 'package:e_rupaiya/services/logger_service.dart';

import '../constants/routes_constant.dart';

const _statusRetryInterval = Duration(seconds: 1);
const _maxStatusAttempts = 3;

/// A reusable processing overlay that can be displayed over any child widget.
///
/// [isProcessing] controls whether the overlay is shown.
/// [message] is the processing title displayed in the bottom panel.
/// [child] is the underlying UI over which the overlay appears.
class ProcessingOverlay extends StatelessWidget {
  const ProcessingOverlay({
    super.key,
    required this.isProcessing,
    required this.message,
    required this.child,
  });

  final bool isProcessing;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isProcessing)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.48),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 411.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(40.w, 72.h, 40.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/png/Vector.png',
                              width: 51.w,
                              height: 50.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 28.h),
                            SizedBox(
                              width: 287.w,
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.black,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              width: 335.w,
                              child: Text(
                                'Your payment is being processed. Please wait a moment and keep this screen open. Do not close the app or press the back button.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF7C7C7C),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 24 / 14,
                                  letterSpacing: -0.28.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ---------------------------------------------------------------------------
// PaymentProcessingOverlay
// ---------------------------------------------------------------------------

/// A full-screen, back-locked payment status checker.
class PaymentProcessingOverlay extends HookConsumerWidget {
  const PaymentProcessingOverlay({
    super.key,
    required this.transactionRefId,
    this.paymentType = 'Education Fees',
    this.recipientName = '',
    this.maskedAccount = '',
    this.accountNo = '',
    this.ifsc = '',
    this.fallbackAmount = '',
    this.paymentId = '',
    this.card,
    this.reportSuccess = false,
    this.message = 'Processing Your Payment...',
  });

  final String transactionRefId;
  final String paymentType;
  final String recipientName;
  final String maskedAccount;
  final String accountNo;
  final String ifsc;
  final String fallbackAmount;
  final String paymentId;
  final EducationCard? card;
  final bool reportSuccess;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      var cancelled = false;

      Future<void> verify() async {
        final referenceId = transactionRefId.trim();
        if (referenceId.isEmpty) {
          logger.error('Payment reference is missing');
          if (context.mounted) {
            context.go(RouteConstants.transactions);
          }
          return;
        }

        final repository = ref.read(educationFeesRepositoryProvider);

        void showResult(EducationPaymentStatusResponse result) {
          if (result.isSuccess && reportSuccess) {
            unawaited(
              _reportSuccessfulPayment(
                repository: repository,
                result: result,
                recipientName: recipientName,
                accountNo: accountNo,
                ifsc: ifsc,
                fallbackAmount: fallbackAmount,
                paymentId: paymentId,
                card: card,
              ),
            );
          }

          final entry = _buildTransactionEntry(
            result: result,
            transactionRefId: referenceId,
            paymentType: paymentType,
            recipientName: recipientName,
            maskedAccount: maskedAccount,
            fallbackAmount: fallbackAmount,
            paymentId: paymentId,
          );
          logger.info(
            'Payment ${result.paymentStatus.toUpperCase()} for $referenceId',
          );
          context.go(
            RouteConstants.transactionDetail,
            extra: <String, dynamic>{
              'entry': entry,
              'fromPaymentFlow': true,
            },
          );
        }

        for (var attempt = 1;
            attempt <= _maxStatusAttempts && !cancelled && context.mounted;
            attempt++) {
          try {
            final result = await repository.fetchPaymentStatus(
              transactionRefId: referenceId,
            );
            if (cancelled || !context.mounted) return;

            if (!result.hasKnownPaymentStatus) {
              throw const FormatException('Unknown payment status');
            }

            final shouldShowImmediately = result.isSuccess || result.isPending;
            if (shouldShowImmediately || attempt == _maxStatusAttempts) {
              showResult(result);
              return;
            }
          } catch (error, stackTrace) {
            if (cancelled || !context.mounted) return;
            logger.error(
              'Payment verification attempt $attempt failed: $error',
              error: error,
              stackTrace: stackTrace,
            );
          }

          if (attempt < _maxStatusAttempts) {
            await Future<void>.delayed(_statusRetryInterval);
          }
        }

        if (!cancelled && context.mounted) {
          context.go(RouteConstants.transactions);
        }
      }

      unawaited(Future<void>.microtask(verify));
      return () => cancelled = true;
    }, const []);

    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: ProcessingOverlay(
          isProcessing: true,
          message: message,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

Future<void> _reportSuccessfulPayment({
  required EducationFeesRepository repository,
  required EducationPaymentStatusResponse result,
  required String recipientName,
  required String accountNo,
  required String ifsc,
  required String fallbackAmount,
  required String paymentId,
  required EducationCard? card,
}) async {
  try {
    await repository.reportPaymentSuccess(
      recipientName: recipientName,
      accountNo: accountNo,
      ifsc: ifsc,
      amount: double.tryParse(result.amount) ??
          double.tryParse(fallbackAmount) ??
          0,
      paymentId: paymentId,
      status: result.paymentStatus.toLowerCase(),
      cardToken: card?.cardToken ?? '',
      last4: card?.last4 ?? '',
      cardNetwork: card?.cardNetwork ?? '',
      expiryMonth: card?.expiryMonth ?? '',
      expiryYear: card?.expiryYear ?? '',
    );
  } catch (error, stackTrace) {
    logger.error(
      'Failed to report successful education payment: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

TransactionHistoryEntry _buildTransactionEntry({
  required EducationPaymentStatusResponse result,
  required String transactionRefId,
  required String paymentType,
  required String recipientName,
  required String maskedAccount,
  required String fallbackAmount,
  required String paymentId,
}) {
  final transactionId =
      result.transactionId.isNotEmpty ? result.transactionId : transactionRefId;
  final rawAmount = result.amount.isNotEmpty ? result.amount : fallbackAmount;
  final amount = _formatAmount(rawAmount);
  final resolvedPaymentType =
      paymentType.trim().isEmpty ? 'Education Fees' : paymentType.trim();

  return TransactionHistoryEntry(
    paymentStatus: result.paymentStatus.trim().toUpperCase(),
    paymentType: resolvedPaymentType,
    billerName:
        recipientName.trim().isEmpty ? resolvedPaymentType : recipientName,
    maskedIdentifier:
        maskedAccount.trim().isEmpty ? transactionId : maskedAccount,
    amount: amount,
    platformFees: '',
    totalAmountCharged: amount,
    customerMobile: '',
    iconUrl: '',
    pgTransactionId: paymentId.trim().isEmpty ? transactionId : paymentId,
    ecoinsTransactionId: '',
    transactionId: transactionId,
    bankReferenceId: '',
    referenceId: transactionRefId,
    transactionTime: result.updatedAt.isNotEmpty
        ? result.updatedAt
        : DateTime.now().toIso8601String(),
    method: 'Razorpay / Online',
    methodIcon: '',
    paymentMode: 'Online',
    vpa: '',
    rrn: '',
    customerParams: [
      TransactionCustomerParam(
        label: 'Payment to',
        value: recipientName.trim().isEmpty
            ? resolvedPaymentType
            : recipientName.trim(),
      ),
      TransactionCustomerParam(
        label: 'Account',
        value: maskedAccount.trim().isEmpty ? transactionId : maskedAccount,
      ),
    ],
    amountBreakdown: {
      'Bill Amount': amount,
      'Total': amount,
    },
  );
}

String _formatAmount(String raw) {
  final value = raw.trim();
  final parsed = double.tryParse(value.replaceAll(',', ''));
  if (parsed == null) return value;
  return parsed.toStringAsFixed(parsed.truncateToDouble() == parsed ? 0 : 2);
}
