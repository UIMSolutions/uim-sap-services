module uim.sap.btp.helpers;

import std.array : appender;
import std.uri : encodeComponent;
import std.base64 : Base64;
import std.format : format;
import std.conv : to;

string normalizePath(string path) {
  if (path.length == 0) {
    return "/";
  }
  return path[0] == '/' ? path : "/" ~ path;
}

string joinUrl(string baseUrl, string path) {
  if (baseUrl.length == 0) {
    return path;
  }

  if (baseUrl[$ - 1] == '/' && path.length > 0 && path[0] == '/') {
    return baseUrl[0 .. $ - 1] ~ path;
  }

  if (baseUrl[$ - 1] != '/' && (path.length == 0 || path[0] != '/')) {
    return baseUrl ~ "/" ~ path;
  }

  return baseUrl ~ path;
}

string buildQuery(string[string] query) {
  if (query is null || query.length == 0) {
    return "";
  }

  auto result = appender!string();
  bool first = true;
  foreach (key, value; query) {
    if (first) {
      result.put('?');
      first = false;
    } else {
      result.put('&');
    }
    result.put(encodeComponent(key));
    result.put('=');
    result.put(encodeComponent(value));
  }
  return result.data;
}

string encodeBasicAuth(string username, string password) {
  auto credentials = username ~ ":" ~ password;
  auto encoded = Base64.encode(cast(ubyte[]) credentials);
  return "Basic " ~ to!string(encoded);
}

string getBearerToken(string token) {
  return "Bearer " ~ token;
}

string createServicePath(string service, string path) {
  if (service.length == 0) {
    return path;
  }
  return "/" ~ service ~ path;
}
