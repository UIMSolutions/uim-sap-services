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
class DSTDestination : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!DSTDestination);

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
  UUID clientId;
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

  override Json toJson()  {
    // Properties
    Json props = Json.emptyObject;
    foreach (k, v; properties)
      props[k] = v;

    return super.toJson()
    .set("name", name)
    .set("description", description)
    .set("url", url)
    .set("protocol", protocol)
    .set("authentication_type", authenticationType)
    .set("proxy_type", proxyType)
    .set("environment", environment)
    .set("user", user)
    .set("password", password.length > 0 ? "***" : "")
    .set("token_service_url", tokenServiceUrl)
    .set("client_id", clientId)
    .set("client_secret", clientSecret.length > 0 ? "***" : "")
    .set("certificate_name", certificateName)
    .set("location_id", locationId)
    .set("sap_client", sapClient)
    .set("properties", props)
    .set("active", active);
  }
}
