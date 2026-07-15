abstract class EconomyEvent {}

class FetchTransactionsEvent extends EconomyEvent {}

class ClaimAdRewardEvent extends EconomyEvent {}

class PurchaseItemEvent extends EconomyEvent {
  final String itemId;

  PurchaseItemEvent(this.itemId);
}
