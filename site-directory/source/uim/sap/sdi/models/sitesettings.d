/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.models.sitesettings;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

struct SDISiteSettings {
  string theme = "sap_horizon";
  string homePage = "home";
  bool allowPersonalization = true;
  bool enableNotifications = true;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["theme"] = theme;
    payload["home_page"] = homePage;
    payload["allow_personalization"] = allowPersonalization;
    payload["enable_notifications"] = enableNotifications;
    return payload;
  }
}


