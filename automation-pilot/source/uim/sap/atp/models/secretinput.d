module uim.sap.atp.models.secretinput;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPSecretInput {
  string tenantId;
  string key;
  string maskedValue;
  string purpose;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["key"] = key;
    payload["masked_value"] = maskedValue;
    payload["purpose"] = purpose;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
