/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.models.subscription;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:
class AlertSubscription : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AlertSubscription);

  UUID subscriptionId;
  string name;
  UUID consumerId;
  bool enabled;
  Json condition;
  Json actions;

  override Json toJson()  {
    return super.toJson()    
      .set("subscription_id", subscriptionId.toJson())
      .set("name", name.toJson())
      .set("consumer_id", consumerId.toJson())
      .set("enabled", enabled.toJson())
      .set("condition", condition.toJson())
      .set("actions", actions.toJson());
  }
}
