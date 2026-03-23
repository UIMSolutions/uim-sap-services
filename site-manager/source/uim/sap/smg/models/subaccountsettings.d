/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.models.subaccountsettings;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

/**
  * Model representing the subaccount settings in the Site Manager.
  * This model includes properties such as the tenant ID, default site ID, launchpad mode, theme ID,
  * content approval settings, transport settings, role-based access enforcement, and metadata about the last change.
  * Example usage:
  * SMGSubaccountSettings settings = ...; // Obtain settings from API or configuration
  * Json jsonPayload = settings.toJson(); // Convert settings to JSON for API response
  *
  * The toJson method can be used to serialize the settings into a JSON format suitable for API responses or storage.
  *
  * Note: The actual properties and their types may vary based on the specific requirements of the Site Manager and the SAP environment.
  *
  * Fields:
  * - tenantId: The unique identifier of the tenant.
  * - defaultSiteId: The ID of the default site for the subaccount.
  * - launchpadMode: The mode of the SAP Fiori launchpad (e.g., "classic", "cloud").
  * - themeId: The ID of the theme applied to the launchpad.
  * - enableContentApproval: Flag indicating whether content approval is enabled.
  * - enableTransport: Flag indicating whether transport is enabled for the subaccount.
  * - enforceRoleBasedAccess: Flag indicating whether role-based access control is enforced.
  * - lastChangedBy: The user who last changed the settings.
  * - updatedAt: The timestamp of the last update to the settings.
  *
  * Methods:
  * - toJson(): Converts the subaccount settings into a JSON object for API responses or storage.
  */
class SMGSubaccountSettings : SAPTenantObject {
  mixin(SAPObjectTemplate!SMGSubaccountSettings);

  UUID defaultSiteId;
  string launchpadMode;
  UUID themeId;
  bool enableContentApproval;
  bool enableTransport;
  bool enforceRoleBasedAccess;
  string lastChangedBy;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson
      .set("default_site_id", defaultSiteId)
      .set("launchpad_mode", launchpadMode)
      .set("theme_id", themeId)
      .set("enable_content_approval", enableContentApproval)
      .set("enable_transport", enableTransport)
      .set("enforce_role_based_access", enforceRoleBasedAccess)
      .set("last_changed_by", lastChangedBy);
  }
}
