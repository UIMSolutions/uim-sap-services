/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.kpi;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Represents a KPI (Key Performance Indicator) in the Datasphere application.
  *
  * This struct is used to capture and store information about KPIs within the Datasphere environment. Each KPI includes details such as the tenant ID, KPI ID, name, formula, unit, and the timestamp of when the KPI was last updated.
  * The `toJson` method allows for easy serialization of KPIs into a JSON format, facilitating storage and integration with logging systems or external monitoring tools.
  * 
  * Fields:
  * - tenantId: The ID of the tenant associated with this KPI.
  * - kpiId: A unique identifier for the KPI.
  * - name: The name of the KPI.
  * - formula: The formula used to calculate the KPI.
  * - unit: The unit of measurement for the KPI.
  * - updatedAt: The timestamp when the KPI was last updated.
  */
struct DATKpi {
  string tenantId;
  string kpiId;
  string name;
  string formula;
  string unit;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["kpi_id"] = kpiId;
    payload["name"] = name;
    payload["formula"] = formula;
    payload["unit"] = unit;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
