/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.models.scaledecision;

import uim.sap.aas;

@safe:

/**
  * Represents a scaling decision for an application, including the current and desired number of instances, 
  * the direction of scaling (up or down), the reason for the decision, and the associated costs.
  *
  * This class is used to encapsulate the details of a scaling decision made by the application autoscaler,
  * allowing for easy serialization to JSON for API responses or logging purposes.
  *
  * Example usage:
  * ```
  * AASScaleDecision decision = new AASScaleDecision();
  * decision.appId = "my-app";
  * decision.currentInstances = 2;
  * decision.desiredInstances = 3;
  * decision.direction = "up";
  * decision.reason = "CPU usage exceeded threshold";
  * decision.currentHourlyCost = 0.10;
  * decision.desiredHourlyCost = 0.15;
  * decision.evaluatedAt = Clock.currTime();
  * Json json = decision.toJson();
  * ```
  */
class AASScaleDecision : SAPObject {
  mixin(SAPObjectTemplate!AASScaleDecision);

  string appId;
  uint currentInstances;
  uint desiredInstances;
  string direction;
  string reason;
  double currentHourlyCost;
  double desiredHourlyCost;
  SysTime evaluatedAt;

  override Json toJson() { 
    return super.toJson() 
      .set("app_id", appId)
      .set("current_instances", cast(long)currentInstances)
      .set("desired_instances", cast(long)desiredInstances)
      .set("direction", direction)
      .set("reason", reason)
      .set("current_hourly_cost", currentHourlyCost)
      .set("desired_hourly_cost", desiredHourlyCost)
      .set("evaluated_at", evaluatedAt.toISOExtString());
  }
}
