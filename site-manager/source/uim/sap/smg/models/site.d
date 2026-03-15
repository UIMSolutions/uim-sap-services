/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.models.site;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

/**
  * Model representing a site in the Site Manager.
  * It includes details such as tenant ID, site ID, site name, description, lifecycle status, assigned roles, pages, catalogs, and timestamps for creation and last update.
  * Example usage:
  * SMGSite site = ...; // Obtain site details from API or configuration
  * Json jsonPayload = site.toJson(); // Convert site details to JSON for API response
  * The toJson method can be used to serialize the site details into a JSON format suitable for API responses or storage.
  * Note: The actual properties and their types may vary based on the specific requirements of the Site Manager and the SAP environment.
  * 
  * Fields:
  * - tenantId: The unique identifier of the tenant.
  * - siteId: The unique identifier of the site.
  * - siteName: The name of the site.
  * - description: A brief description of the site.
  * - lifecycle: The lifecycle status of the site (e.g., "active", "inactive").
  * - assignedRoles: An array of roles assigned to the site.
  * - pages: An array of page IDs associated with the site.
  * - catalogs: An array of catalog IDs associated with the site.
  * - createdAt: The timestamp when the site was created.
  * - updatedAt: The timestamp when the site was last updated.
  *
  * Methods:
  * - toJson(): Converts the site details into a JSON object for API responses or storage.
  */
struct SMGSite {
  string tenantId;
  string siteId;
  string siteName;
  string description;
  string lifecycle;
  string[] assignedRoles;
  string[] pages;
  string[] catalogs;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["site_id"] = siteId;
    payload["site_name"] = siteName;
    payload["description"] = description;
    payload["lifecycle"] = lifecycle;
    Json assignedRoleValues = Json.emptyArray;
    foreach (role; assignedRoles)
      assignedRoleValues ~= role;
    payload["assigned_roles"] = assignedRoleValues;

    Json pageValues = Json.emptyArray;
    foreach (page; pages)
      pageValues ~= page;
    payload["pages"] = pageValues;

    Json catalogValues = Json.emptyArray;
    foreach (catalog; catalogs)
      catalogValues ~= catalog;
    payload["catalogs"] = catalogValues;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
