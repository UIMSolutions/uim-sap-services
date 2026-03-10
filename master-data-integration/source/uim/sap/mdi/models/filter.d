module uim.sap.mdi.models.filter;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

/**
  * Represents a filter configuration for Master Data Integration.
  *
  * Each filter is associated with a specific tenant and object type, and contains conditions that define how data should be filtered during integration processes. The `active` flag indicates whether the
  * filter is currently active and should be applied. The `updatedAt` timestamp helps track when the filter was last modified.
  *
  * Example usage:
  * ```
  * MDIFilter filter;
  * filter.tenantId = "tenant123";
  * filter.filterId = "filter456";
  * filter.objectType = "Product";
  * filter.conditions = Json("{"field": "category", "operator": "equals", "value": "Electronics"}");
  * filter.active = true;
  * filter.updatedAt = Clock.currTime();
  * ```
  * Fields:
  * - `tenantId`: The ID of the tenant to which this filter belongs.
  * - `filterId`: A unique identifier for the filter.
  * - `objectType`: The type of object this filter applies to (e.g., "Product", "Customer").
  * - `conditions`: A JSON object representing the filter conditions.
  * - `active`: A boolean indicating whether the filter is active.  
  * - `updatedAt`: A timestamp indicating when the filter was last updated.
  */
struct MDIFilter {
  string tenantId;
  string filterId;
  string objectType;
  Json conditions;
  bool active;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["filter_id"] = filterId;
    payload["object_type"] = objectType;
    payload["conditions"] = conditions;
    payload["active"] = active;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
