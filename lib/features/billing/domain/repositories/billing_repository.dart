abstract class BillingRepository {
  /// Stream of premium status (true = purchased)
  Stream<bool> get isPremiumStream;

  /// Initiate purchase flow for the premium pack
  Future<void> purchasePremium();

  /// Restore previous purchases
  Future<void> restorePurchases();

  /// Check initial state on app start
  Future<void> initialize();

  /// Purchase a consumable product (like a video template)
  Future<void> buyConsumable(String productId);
}
