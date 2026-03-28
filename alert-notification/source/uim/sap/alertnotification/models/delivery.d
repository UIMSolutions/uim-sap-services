/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.models.delivery;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertDelivery : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AlertDelivery);

  UUID deliveryId;
  UUID alertId;
  UUID subscriptionId;
  string actionType;
  string target;
  string status;
  string reason;

  override Json toJson() {
    return super.toJson()
      .set("delivery_id", deliveryId.toJson())
      .set("alert_id", alertId.toJson())
      .set("subscription_id", subscriptionId.toJson())
      .set("action_type", actionType.toJson())
      .set("target", target.toJson())
      .set("status", status.toJson())
      .set("reason", reason.toJson());
  }
}
