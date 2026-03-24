module uim.sap.atm.models.identityprovider;

class ATMIdentityProvider : SAPTenantObject {
  mixin(SAPObjectTemplate!ATMIdentityProvider);

  UUID idpId;
  string name;
  string providerType = "oidc";
  string issuer;
  string audience;
  string description;
  bool enabled = true;
  bool isDefault = false;
  string[] trustedAlgorithms;

  override Json toJson()  {
    Json trusted = trustedAlgorithms.map!(a => a.toJson).array.toJson;

    return super.toJson
    .set("tenant_id", tenantId.toJson)
    .set("idp_id", idpId.toJson)
    .set("name", name.toJson)
    .set("provider_type", providerType.toJson)
    .set("issuer", issuer.toJson)
    .set("audience", audience.toJson)
    .set("description", description.toJson)
    .set("enabled", enabled.toJson)
    .set("is_default", isDefault.toJson)
    .set("trusted_algorithms", trusted.toJson)
    .set("updated_at", updatedAt.toISOExtString().toJson);
  }
}

ATMIdentityProvider idpFromJson(UUID tenantId, string idpId, Json request) {
  ATMIdentityProvider idp = new ATMIdentityProvider(request);
  idp.tenantId = tenantId;
  idp.idpId = idpId.length > 0 ? idpId : randomUUID().toString();
  idp.name = idp.idpId;
  idp.trustedAlgorithms = ["RS256", "ES256", "HS256", "none"];
  idp.updatedAt = Clock.currTime();

  if ("name" in request && request["name"].isString) {
    idp.name = request.getString("name");
  }
  if ("provider_type" in request && request["provider_type"].isString) {
    idp.providerType = request.getString("provider_type");
  }
  if ("issuer" in request && request["issuer"].isString) {
    idp.issuer = request.getString("issuer");
  }
  if ("audience" in request && request["audience"].isString) {
    idp.audience = request.getString("audience");
  }
  if ("description" in request && request["description"].isString) {
    idp.description = request.getString("description");
  }
  if ("enabled" in request && request["enabled"].isBoolean) {
    idp.enabled = optionalBoolean("enabled");
  }
  if ("is_default" in request && request["is_default"].isBoolean) {
    idp.isDefault = optionalBoolean("is_default");
  }
  if ("trusted_algorithms" in request && request["trusted_algorithms"].isArray) {
    idp.trustedAlgorithms = stringArrayFromJson(request["trusted_algorithms"]);
  }

  return idp;
}
