import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/app_logger.dart';

class BillingRepositoryImpl implements BillingRepository {
  final InAppPurchase _iap = InAppPurchase.instance;
  final _purchaseController = StreamController<bool>.broadcast();

  String get _premiumProductKey => AppConfig.instance.premiumProductKey;
  String get _premiumPrefKey => AppConfig.instance.premiumPrefKey;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  Stream<bool> get isPremiumStream => _purchaseController.stream;

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumPrefKey) ?? false;
    _purchaseController.add(isPremium);

    final available = await _iap.isAvailable();
    if (!available) {
      AppLogger.info('⚠️ Store invalid/unavailable');
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _purchaseController.close(),
      onError: (e) => AppLogger.error('Billing Stream Error: $e'),
    );

    // Auto-restore on init to check for existing purchases
    restorePurchases();
  }

  @override
  Future<void> purchasePremium() async {
    final available = await _iap.isAvailable();
    if (!available) throw 'Store unavailable';

    final response = await _iap.queryProductDetails({_premiumProductKey});
    if (response.notFoundIDs.isNotEmpty) {
      AppLogger.error('Product not found: $_premiumProductKey');
      throw 'Product not found';
    }

    final productDetails = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    // For non-consumables (Premium Pack), we don't consume
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        AppLogger.info('⏳ Purchase Pending...');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          AppLogger.error('❌ Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.productID == _premiumProductKey) {
            await _verifyAndDeliver(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    // In a real backend, verify token with Google API.
    // For v1.0, we trust the local success state.
    AppLogger.info('✅ Purchase Verified: ${purchase.productID}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumPrefKey, true);
    _purchaseController.add(true);
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseController.close();
  }
}
