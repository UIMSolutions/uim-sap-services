/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cdc.models.auth_event;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

class CDCAuthEvent : SAPTenantObject {
  mixin(SAPObjectTemplate!CDCAuthEvent);

  UUID eventId;
  UUID userId;
  UUID providerId;
  string ipAddress;
  string decision;
  string riskLevel;
  long riskScore;
  Json providerSignals;

  override Json toJson()  {
    return super.toJson
      .set("event_id", eventId)
      .set("user_id", userId)
      .set("provider_id", providerId)
      .set("ip_address", ipAddress)
      .set("decision", decision)
      .set("risk_level", riskLevel)
      .set("risk_score", riskScore)
      .set("provider_signals", providerSignals);
  }
}
