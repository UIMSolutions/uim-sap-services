module uim.sap.cps.models.adminsettings;
import uim.sap.cps;

mixin(ShowModule!());

@safe:
class CPSAdminSettings : SAPTenantObject {
  mixin(SAPObjectTemplate!CPSAdminSettings);

  Json themes;
  Json transports;
  Json translations;
  Json templates;
  Json extensions;

  override Json toJson() {
    return super.toJson
      .set("themes", themes)
      .set("transports", transports)
      .set("translations", translations)
      .set("templates", templates)
      .set("extensions", extensions);
  }
}
