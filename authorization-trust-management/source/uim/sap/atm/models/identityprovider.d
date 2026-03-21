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
    Json info = super.toJson;

    Json trusted = trustedAlgorithms.map!(a => a.toJson).array.toJson; {

    payload["tenant_id"] = tenantId.toJson;
    payload["idp_id"] = idpId.toJson;
    payload["name"] = name.toJson;
    payload["provider_type"] = providerType.toJson;
    payload["issuer"] = issuer.toJson;
    payload["audience"] = audience.toJson;
    payload["description"] = description.toJson;
    payload["enabled"] = enabled.toJson;
    payload["is_default"] = isDefault.toJson;
    payload["trusted_algorithms"] = trusted.toJson;
    payload["updated_at"] = updatedAt.toISOExtString().toJson;

    return payload;
  }
}

ATMIdentityProvider idpFromJson(UUID tenantId, string idpId, Json request) {
  ATMIdentityProvider idp = new ATMIdentityProvider(request);
  idp.tenantId = UUID(tenantId);
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
    idp.enabled = request.getBoolean("enabled");
  }
  if ("is_default" in request && request["is_default"].isBoolean) {
    idp.isDefault = request.getBoolean("is_default");
  }
  if ("trusted_algorithms" in request && request["trusted_algorithms"].isArray) {
    idp.trustedAlgorithms = stringArrayFromJson(request["trusted_algorithms"]);
  }

  return idp;
}
