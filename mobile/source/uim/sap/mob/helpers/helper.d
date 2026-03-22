/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mob.helpers.helper;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Validate an application or resource identifier
bool isValidAppId(string id) pure nothrow {
  if (id.length == 0 || id.length > 253)
    return false;
  foreach (c; id) {
    if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' || c == '.' || c == '_'))
      return false;
  }
  return true;
}

/// Build composite key for app-scoped resources
string appKey(string appId, UUID resourceId) pure nothrow {
  return appId ~ "/" ~ resourceId;
}
