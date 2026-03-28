module uim.sap.atp.models.secretinput;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
  * Represents a secret input associated with an ATP command, such as credentials or API keys.
  * The actual value is not stored, only a masked version for display purposes.
  *
  * Fields:
  * - key: The identifier for the secret
  * - maskedValue: A masked version of the secret value (e.g., "****") for display purposes.
  * - purpose: A description of what the secret is used for (e.g., "database password", "API key for external service").
  * Methods:
  * - toJson(): Serializes the secret input object to JSON format for storage or transmission.
  */
class ATPSecretInput : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!ATPSecretInput);

  string key;
  string maskedValue;
  string purpose;

  override Json toJson() {
    return super.toJson
      .set("tenant_id", tenantId)
      .set("key", key)
      .set("masked_value", maskedValue)
      .set("purpose", purpose)
      .set("updated_at", updatedAt.toISOExtString());
  }
}
