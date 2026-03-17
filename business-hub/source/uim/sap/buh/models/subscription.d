/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.buh.models.subscription;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHSubscription : SAPObject {
  mixin(SAPObjectTemplate!BUHSubscription);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("api_id" in initData && initData["api_id"].isString) {
      apiId = initData["api_id"].get!string;
    }
    if ("application_name" in initData && initData["application_name"].isString) {
      applicationName = initData["application_name"].get!string;
    }
    if ("plan" in initData && initData["plan"].isString) {
      plan = initData["plan"].get!string;
    }

    return true;
  }

  UUID id;
  UUID apiId;
  string applicationName;
  string plan;
  string status = "active";

  override Json toJson()  {
    return super.toJson
      .set("id", id)
      .set("api_id", apiId)
      .set("application_name", applicationName)
      .set("plan", plan)
      .set("status", status);
  }

  BUHSubscription subscriptionFromJson(Json payload) {
    BUHSubscription subscription = new BUHSubscription(payload);
    subscription.id = randomUUID().toString();
    subscription.createdAt = Clock.currTime();

    return subscription;
  }
}


