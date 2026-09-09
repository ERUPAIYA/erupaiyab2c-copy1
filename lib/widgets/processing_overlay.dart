import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:e_rupaiya/features/educationFees/controllers/education_fees_controller.dart';
import 'package:e_rupaiya/features/educationFees/models/education_fees_responses.dart';
import 'package:e_rupaiya/features/educationFees/repositories/education_fees_repository.dart';
import 'package:e_rupaiya/features/profile/models/transaction_history_entry.dart';
import 'package:e_rupaiya/services/logger_service.dart';

import '../constants/routes_constant.dart';

const _statusPollInterval = Duration(seconds: 2);
const _pendingResolutionWindow = Duration(seconds: 6);

/// A reusable processing overlay that can be displayed over any child widget.
///
/// [isProcessing] controls whether the overlay is shown.
/// [message] is the text displayed below the spinner.
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
              child: Container(
                color: Colors.black.withValues(alpha: 0.24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
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
    this.message = 'Payment is being processed...',
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
    final isProcessing = useState(true);
    final processingMessage = useState(message);
    final errorMessage = useState<String?>(null);
    final retryToken = useState(0);

    useEffect(() {
      var cancelled = false;

      Future<void> verify() async {
        final referenceId = transactionRefId.trim();
        if (referenceId.isEmpty) {
          isProcessing.value = false;
          errorMessage.value =
              'The payment reference is missing. Please check transaction history.';
          return;
        }

        final repository = ref.read(educationFeesRepositoryProvider);
        var consecutiveErrors = 0;
        final processingStartedAt = DateTime.now();

        while (!cancelled && context.mounted) {
          try {
            final result = await repository.fetchPaymentStatus(
              transactionRefId: referenceId,
            );
            if (cancelled || !context.mounted) return;

            if (!result.hasKnownPaymentStatus) {
              throw const FormatException('Unknown payment status');
            }

            consecutiveErrors = 0;
            if (result.isProcessing) {
              processingMessage.value = message;
              await Future<void>.delayed(_statusPollInterval);
              continue;
            }

            if (result.isPending) {
              final elapsed = DateTime.now().difference(processingStartedAt);
              if (elapsed < _pendingResolutionWindow) {
                final remaining = _pendingResolutionWindow - elapsed;
                await Future<void>.delayed(
                  remaining < _statusPollInterval
                      ? remaining
                      : _statusPollInterval,
                );
                continue;
              }
            }

            if (cancelled || !context.mounted) {
              return;
            }

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
            return;
          } catch (error, stackTrace) {
            if (cancelled || !context.mounted) return;
            consecutiveErrors++;
            logger.error(
              'Payment verification attempt failed: $error',
              error: error,
              stackTrace: stackTrace,
            );
            if (consecutiveErrors >= 5) {
              isProcessing.value = false;
              errorMessage.value =
                  'We could not confirm the payment status. Please try again or check transaction history.';
              return;
            }
            processingMessage.value =
                'Confirming your payment status. Please wait...';
            await Future<void>.delayed(_statusPollInterval);
          }
        }
      }

      unawaited(Future<void>.microtask(verify));
      return () => cancelled = true;
    }, [retryToken.value]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !isProcessing.value) {
          context.go(RouteConstants.transactions);
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: isProcessing.value
            ? ProcessingOverlay(
                isProcessing: true,
                message: processingMessage.value,
                child: const SizedBox.expand(),
              )
            : ColoredBox(
                color: Colors.white,
                child: _PaymentStatusError(
                  message: errorMessage.value ?? 'Unable to verify payment.',
                  onRetry: () {
                    isProcessing.value = true;
                    errorMessage.value = null;
                    processingMessage.value = message;
                    retryToken.value++;
                  },
                  onViewHistory: () => context.go(RouteConstants.transactions),
                ),
              ),
      ),
    );
  }
}

class _PaymentStatusError extends StatelessWidget {
  const _PaymentStatusError({
    required this.message,
    required this.onRetry,
    required this.onViewHistory,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 52.r),
              SizedBox(height: 18.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry status check'),
                ),
              ),
              TextButton(
                onPressed: onViewHistory,
                child: const Text('View transaction history'),
              ),
            ],
          ),
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
