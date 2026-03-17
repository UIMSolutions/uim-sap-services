/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.models.destination;

import uim.sap.dst;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// DSTDestination – a configured destination (connection to remote service)
// ---------------------------------------------------------------------------
struct DSTDestination {
  string tenantId;
  /// Unique name within a tenant (used as lookup key)
  string name;
  string description;
  /// URL / hostname of the remote service
  string url;
  /// Protocol: "HTTP" | "RFC" | "LDAP" | "MAIL" | "TCP"
  string protocol;
  /// Authentication type:
  ///   "NoAuthentication" | "BasicAuthentication" | "OAuth2ClientCredentials"
  ///   "OAuth2SAMLBearerAssertion" | "OAuth2UserTokenExchange"
  ///   "ClientCertificateAuthentication" | "PrincipalPropagation"
  ///   "SAMLAssertion" | "OAuth2JWTBearer" | "OAuth2Password"
  string authenticationType;
  /// Proxy type: "Internet" | "OnPremise" | "PrivateLink"
  string proxyType;
  /// Target environment: "cloud-foundry" | "kyma" | "abap" | "kubernetes"
  string environment;
  /// User / client credentials
  string user;
  string password; // stored but masked in output
  /// OAuth2 fields
  string tokenServiceUrl;
  string clientId;
  string clientSecret; // stored but masked in output
  /// Certificate name (reference to DSTCertificate)
  string certificateName;
  /// Cloud Connector location ID (for OnPremise)
  string locationId;
  /// SAP Client (RFC / ABAP)
  string sapClient;
  /// Custom key-value properties
  string[string] properties;
  bool active;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["name"] = name;
    j["description"] = description;
    j["url"] = url;
    j["protocol"] = protocol;
    j["authentication_type"] = authenticationType;
    j["proxy_type"] = proxyType;
    j["environment"] = environment;
    j["user"] = user;
    j["password"] = password.length > 0 ? "***" : "";
    j["token_service_url"] = tokenServiceUrl;
    j["client_id"] = clientId;
    j["client_secret"] = clientSecret.length > 0 ? "***" : "";
    j["certificate_name"] = certificateName;
    j["location_id"] = locationId;
    j["sap_client"] = sapClient;
    // Properties
    Json props = Json.emptyObject;
    foreach (k, v; properties)
      props[k] = v;
    j["properties"] = props;
    j["active"] = active;
    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    return j;
  }
}
