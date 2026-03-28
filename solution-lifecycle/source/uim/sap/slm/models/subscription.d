module uim.sap.slm.models.subscription;

// ---------------------------------------------------------------------------
// SLMSubscription – a multitenant subscription from a consumer subaccount
// ---------------------------------------------------------------------------
class SLMSubscription : SAPTenantObject {
  mixin(SAPtenantObject!SLMSubscription);

  UUID subscriptionId;
  UUID solutionId;
  /// The subscribing (consumer) subaccount
  UUID consumerSubaccountId;
  UUID consumerTenantId;
  /// Status: "subscribed" | "unsubscribing" | "unsubscribed" | "error"
  string status;
  /// License entitlement reference
  UUID entitlementId;
  string subscribedBy;
  SysTime subscribedAt;
  SysTime unsubscribedAt;

  override Json toJson() {
    return super.toJson()
      .set("subscription_id", subscriptionId)
      .set("solution_id", solutionId)
      .set("consumer_subaccount_id", consumerSubaccountId)
      .set("consumer_tenant_id", consumerTenantId)
      .set("status", status)
      .set("entitlement_id", entitlementId)
      .set("subscribed_by", subscribedBy)
      .set("subscribed_at", subscribedAt.toISOExtString())
      .set("unsubscribed_at", unsubscribedAt.toISOExtString());
  }
}
