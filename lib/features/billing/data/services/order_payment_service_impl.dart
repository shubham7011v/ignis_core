import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../domain/services/order_payment_service.dart';
import '../../../../core/utils/app_logger.dart';

class OrderPaymentServiceImpl implements OrderPaymentService {
  final BillingRepository _billingRepository;
  final InAppPurchase _iap = InAppPurchase.instance;

  OrderPaymentServiceImpl({required BillingRepository billingRepository})
    : _billingRepository = billingRepository;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  @override
  Future<String> purchaseTemplate(String templateId) async {
    // Determine product ID (Assuming a convention or mapping)
    // For now, let's assume the template ID is the product ID or we have a prefix
    final productId = 'template_$templateId';

    AppLogger.info(
      'Initiating purchase for template: $templateId (Product: $productId)',
    );

    // Start listening for this specific product's success
    final completer = Completer<String>();

    StreamSubscription<List<PurchaseDetails>>? subscription;

    subscription = _iap.purchaseStream.listen((purchaseDetailsList) {
      for (var purchase in purchaseDetailsList) {
        if (purchase.productID == productId) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            final token = purchase.verificationData.serverVerificationData;
            AppLogger.info('Purchase successful for $productId. Token: $token');

            if (!completer.isCompleted) {
              completer.complete(token);
              subscription?.cancel();
            }
          } else if (purchase.status == PurchaseStatus.error) {
            AppLogger.error(
              'Purchase failed for $productId: ${purchase.error}',
            );
            if (!completer.isCompleted) {
              completer.completeError(purchase.error ?? 'Unknown error');
              subscription?.cancel();
            }
          }
        }
      }
    });

    try {
      await _billingRepository.buyConsumable(productId);

      // Wait for the stream update (with timeout)
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          subscription?.cancel();
          throw 'Purchase timed out';
        },
      );
    } catch (e) {
      subscription.cancel();
      rethrow;
    }
  }
}
