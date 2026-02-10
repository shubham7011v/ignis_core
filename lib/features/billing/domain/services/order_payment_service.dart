import 'package:in_app_purchase/in_app_purchase.dart';

abstract class OrderPaymentService {
  /// Initiates the purchase of a template.
  /// Returns the purchase token on success.
  Future<String> purchaseTemplate(String templateId);

  /// Listens to purchase updates.
  Stream<List<PurchaseDetails>> get purchaseStream;
}
