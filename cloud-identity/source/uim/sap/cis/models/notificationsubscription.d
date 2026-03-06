/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.notificationsubscription;

import uim.sap.cis;

mixin(ShowModule!());

@safe:
struct CISNotificationSubscription {
  string tenantId;
  string subscriptionId;
  string sourceSystem;
  string callbackUrl;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["subscription_id"] = subscriptionId;
    payload["tenant_id"] = tenantId;
    payload["source_system"] = sourceSystem;
    payload["callback_url"] = callbackUrl;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
