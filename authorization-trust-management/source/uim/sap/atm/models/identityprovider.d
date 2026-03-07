module uim.sap.atm.models.identityprovider;

struct ATMIdentityProvider {
  string tenantId;
  string idpId;
  string name;
  string providerType = "oidc";
  string issuer;
  string audience;
  string description;
  bool enabled = true;
  bool isDefault = false;
  string[] trustedAlgorithms;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    Json trusted = Json.emptyArray;
    foreach (algorithm; trustedAlgorithms) {
      trusted ~= algorithm;
    }

    payload["tenant_id"] = tenantId;
    payload["idp_id"] = idpId;
    payload["name"] = name;
    payload["provider_type"] = providerType;
    payload["issuer"] = issuer;
    payload["audience"] = audience;
    payload["description"] = description;
    payload["enabled"] = enabled;
    payload["is_default"] = isDefault;
    payload["trusted_algorithms"] = trusted;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

ATMIdentityProvider idpFromJson(string tenantId, string idpId, Json request) {
  ATMIdentityProvider idp;
  idp.tenantId = tenantId;
  idp.idpId = idpId.length > 0 ? idpId : randomUUID().toString();
  idp.name = idp.idpId;
  idp.trustedAlgorithms = ["RS256", "ES256", "HS256", "none"];
  idp.updatedAt = Clock.currTime();

  if ("name" in request && request["name"].isString) {
    idp.name = request["name"].get!string;
  }
  if ("provider_type" in request && request["provider_type"].isString) {
    idp.providerType = request["provider_type"].get!string;
  }
  if ("issuer" in request && request["issuer"].isString) {
    idp.issuer = request["issuer"].get!string;
  }
  if ("audience" in request && request["audience"].isString) {
    idp.audience = request["audience"].get!string;
  }
  if ("description" in request && request["description"].isString) {
    idp.description = request["description"].get!string;
  }
  if ("enabled" in request && request["enabled"].isBoolean) {
    idp.enabled = request["enabled"].get!bool;
  }
  if ("is_default" in request && request["is_default"].isBoolean) {
    idp.isDefault = request["is_default"].get!bool;
  }
  if ("trusted_algorithms" in request && request["trusted_algorithms"].type == Json.Type.array) {
    idp.trustedAlgorithms = stringArrayFromJson(request["trusted_algorithms"]);
  }

  return idp;
}
