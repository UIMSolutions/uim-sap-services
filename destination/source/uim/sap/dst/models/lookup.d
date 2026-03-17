/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.models.lookup;

import uim.sap.dst;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// DSTLookupResult – the result of a runtime destination lookup
// ---------------------------------------------------------------------------
struct DSTLookupResult {
  string destinationName;
  string url;
  string protocol;
  string authenticationType;
  string proxyType;
  string environment;
  /// Resolved auth token (if OAuth flow was performed)
  string authToken;
  /// Headers to inject when calling the destination
  string[string] headers;
  /// Custom properties forwarded to the caller
  string[string] properties;
  SysTime resolvedAt;

  Json toJson()  {
    Json props = Json.emptyObject;
    foreach (k, v; properties)
      props[k] = v;

    Json hdr = Json.emptyObject;
    foreach (k, v; headers)
      hdr[k] = v;

    return Json.emptyObject
      .set("destination_name", destinationName)
      .set("url", url)
      .set("protocol", protocol)
      .set("authentication_type", authenticationType)
      .set("proxy_type", proxyType)
      .set("environment", environment)
      .set("auth_token", authToken.length > 0 ? "***" : "")
      .set("headers", hdr)
      .set("properties", props)
      .set("resolved_at", resolvedAt.toISOExtString());
  }
}
