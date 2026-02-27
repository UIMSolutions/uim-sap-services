module uim.sap.btp.client;

import std.json : JSONValue, parseJSON;
import std.string : format;
import vibe.http.client : requestHTTP, HTTPClientRequest, HTTPClientResponse;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAllUTF8;

import uim.sap.btp.config;
import uim.sap.btp.helpers;

class BTPClient {
  private BTPConfig cfg;

  this(BTPConfig cfg) {
    this.cfg = cfg;
  }

  @property BTPConfig config() {
    return cfg;
  }

  JSONValue get(string path, string[string] query = null, string service = "") {
    return request(HTTPMethod.GET, path, query, "", service);
  }

  JSONValue post(string path, string[string] query, string body, string service = "") {
    return request(HTTPMethod.POST, path, query, body, service);
  }

  JSONValue getApplications() {
    return get("/v2/apps", null, "cf");
  }

  JSONValue getSpaces() {
    return get("/v2/spaces", null, "cf");
  }

  JSONValue getOrganizations() {
    return get("/v2/organizations", null, "cf");
  }

  JSONValue getBoundServices() {
    return get("/v2/service_bindings", null, "cf");
  }

  private JSONValue request(
    HTTPMethod method,
    string path,
    string[string] query,
    string body,
    string service = ""
  ) {
    auto baseUrl = getBaseUrl(cfg);
    auto servicePath = createServicePath(service, normalizePath(path));
    auto queryString = buildQuery(query);
    auto url = baseUrl ~ servicePath ~ queryString;

    HTTPClientResponse response = requestHTTP(url, (scope HTTPClientRequest req) {
      req.method = method;
      
      // Set authentication
      if (cfg.useOAuth2 && cfg.accessToken.length > 0) {
        req.headers["Authorization"] = getBearerToken(cfg.accessToken);
      } else if (cfg.username.length > 0 && cfg.password.length > 0) {
        req.headers["Authorization"] = encodeBasicAuth(cfg.username, cfg.password);
      }
      
      req.headers["Content-Type"] = "application/json";
      req.headers["Accept"] = "application/json";

      if (body.length > 0) {
        req.writeBody(cast(const(ubyte)[])body, "application/json");
      }
    });

    auto content = response.bodyReader.readAllUTF8();
    if (content.length == 0) {
      return JSONValue(null);
    }

    // Try to parse as JSON, fall back to null if not JSON
    try {
      return parseJSON(content);
    } catch (Throwable) {
      return JSONValue(null);
    }
  }
}
