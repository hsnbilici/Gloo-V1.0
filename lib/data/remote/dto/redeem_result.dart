/// Redeem code islem sonucu.
sealed class RedeemResult {
  const RedeemResult();

  /// Basarili — urun ID listesi doner.
  const factory RedeemResult.success(List<String> productIds) = RedeemSuccess;

  /// Kullanici bu kodu daha once kullanmis.
  static const RedeemResult alreadyRedeemed = RedeemAlreadyRedeemed();

  /// Gecersiz kod, suresi dolmus veya baska hata.
  static const RedeemResult error = RedeemError();
}

class RedeemSuccess extends RedeemResult {
  const RedeemSuccess(this.productIds);
  final List<String> productIds;
}

class RedeemAlreadyRedeemed extends RedeemResult {
  const RedeemAlreadyRedeemed();
}

class RedeemError extends RedeemResult {
  const RedeemError();
}
