module uim.sap.slm.models.subscription;

// ---------------------------------------------------------------------------
// SLMSubscription – a multitenant subscription from a consumer subaccount
// ---------------------------------------------------------------------------
struct SLMSubscription {
  UUID tenantId;
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
      .set("tenant_id", tenantId)
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
