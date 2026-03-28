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
class MDIFilter : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!MDIFilter);

  UUID filterId;
  string objectType;
  Json conditions;
  bool active;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson
      .set("tenant_id", tenantId)
      .set("filter_id", filterId)
      .set("object_type", objectType)
      .set("conditions", conditions)
      .set("active", active)
      .set("updated_at", updatedAt.toISOExtString());
  }
}
