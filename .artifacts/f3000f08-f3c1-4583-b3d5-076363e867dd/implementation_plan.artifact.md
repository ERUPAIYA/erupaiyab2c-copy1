# Update Transaction Pending UI to Match Design

Match the UI of the Transaction Pending screen to the provided design image, focusing on colors, spacing, and layout accuracy.

## Proposed Changes

### [lib/features/profile/views/transaction_detail_screen.dart](file:///Users/apple/Desktop/erupaiyab2c-copy1/lib/features/profile/views/transaction_detail_screen.dart)

#### [MODIFY] [transaction_detail_screen.dart](file:///Users/apple/Desktop/erupaiyab2c-copy1/lib/features/profile/views/transaction_detail_screen.dart)
- Update `_statusMeta` for `PENDING` with improved gradient colors.
- Simplify `detailRows` to show a single "Transaction ID" by merging PG and Wallet IDs if necessary.
- Adjust header height and card positioning to match the design's proportions.
- Increase border radius for the white transaction card.
- Refine action buttons and the bottom "Done" button layout.
- Update "powered by" logo layout.

## Verification Plan

### Manual Verification
- The user will verify the UI against the provided expected image.
