# Bypass Razorpay for Education Fees Success Scenario

Bypass the Razorpay payment gateway in the Education Fees feature to directly test the success flow using a static status response from the backend.

## Proposed Changes

### Education Fees Views

#### [MODIFY] [EducationFeesPaymentView](file:///Users/apple/Desktop/erupaiyab2c-copy1/lib/features/educationFees/views/education_fees_payment_view.dart)
- Update `onPayNow` callback in `openSummary` to bypass `RazorpayService.instance.openCheckout`.
- Directly call `_verifyEducationPaymentStatus` using `order.transactionRefId` after creating the order.
- Navigate to the transaction detail screen if the status is success.

#### [MODIFY] [EducationFeesTutorsView](file:///Users/apple/Desktop/erupaiyab2c-copy1/lib/features/educationFees/views/education_fees_tutors_view.dart)
- Update `onPayNow` callback in `openSummary` to bypass `RazorpayService.instance.openCheckout`.
- Directly call `_verifyEducationPaymentStatus` using `order.transactionRefId` after creating the order.
- Navigate to the transaction detail screen if the status is success.

## Verification Plan

### Manual Verification
- Navigate to Education Fees.
- Enter payment details and proceed to the payment summary.
- Click "Pay Now".
- Verify that the app bypasses the Razorpay checkout and goes directly to the "Transaction Detail" (Success) screen after a short delay (polling the status API).
