module uim.sap.atm.service;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMService : SAPService {
  mixin(SAPServiceTemplate!ATMService);

  private ATMStore _store;

  this(ATMConfig config) {
    super(config);

    _store = new ATMStore;
  }

  Json upsertIdentityProvider(UUID tenantId, string idpId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(idpId, "Identity provider ID");

    ensureTenantBootstrapped(tenantId);

    auto idp = idpFromJson(tenantId, idpId, request);
    if (idp.name.length == 0) {
      throw new ATMValidationException("IdP name is required");
    }
    if (idp.issuer.length == 0) {
      throw new ATMValidationException("IdP issuer is required");
    }

    idp.updatedAt = Clock.currTime();
    auto saved = _store.upsertIdp(idp);

    return Json.emptyObject
      .set("success", true)
      .set("identity_provider", saved.toJson());
  }

  Json listIdentityProviders(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    ensureTenantBootstrapped(tenantId);

    Json resources = Json.emptyArray;
    foreach (idp; _store.listIdps(tenantId)) {
      resources ~= idp.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json setDefaultIdentityProvider(UUID tenantId, string idpId) {
    validateId(tenantId, "Tenant ID");
    validateId(idpId, "Identity provider ID");
    ensureTenantBootstrapped(tenantId);

    auto idp = _store.setDefaultIdp(tenantId, idpId);
    if (idp.idpId.length == 0) {
      throw new ATMNotFoundException("Identity provider", tenantId ~ "/" ~ idpId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("identity_provider", idp.toJson());
  }

  Json upsertTechnicalRole(UUID tenantId, string roleId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(roleId, "Technical role ID");
    ensureTenantBootstrapped(tenantId);

    auto role = technicalRoleFromJson(tenantId, roleId, request);
    if (role.name.length == 0) {
      throw new ATMValidationException("Technical role name is required");
    }
    if (role.permissions.length == 0) {
      throw new ATMValidationException("At least one permission is required");
    }

    role.updatedAt = Clock.currTime();
    auto saved = _store.upsertTechnicalRole(role);

    return Json.emptyObject
      .set("success", true)
      .set("technical_role", saved.toJson());
  }

  Json listTechnicalRoles(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    ensureTenantBootstrapped(tenantId);

    Json resources = Json.emptyArray;
    foreach (role; _store.listTechnicalRoles(tenantId)) {
      resources ~= role.toJson();
    }

    return super.toJson()
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertRoleCollection(UUID tenantId, string collectionId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(collectionId, "Role collection ID");
    ensureTenantBootstrapped(tenantId);

    auto collection = roleCollectionFromJson(tenantId, collectionId, request);
    if (collection.name.length == 0) {
      throw new ATMValidationException("Role collection name is required");
    }

    foreach (roleId; collection.technicalRoleIds) {
      auto role = _store.getTechnicalRole(tenantId, roleId);
      if (role.roleId.length == 0) {
        throw new ATMNotFoundException("Technical role", tenantId ~ "/" ~ roleId);
      }
    }

    collection.updatedAt = Clock.currTime();
    auto saved = _store.upsertRoleCollection(collection);

    return Json.emptyObject
      .set("success", true)
      .set("role_collection", saved.toJson());
  }

  Json listRoleCollections(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    ensureTenantBootstrapped(tenantId);

    Json resources = _store.listRoleCollections(tenantId).map!(collection => collection.toJson).array.toJson;

    return super.toJson()
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertUserAssignments(UUID tenantId, string userId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(userId, "User ID");
    ensureTenantBootstrapped(tenantId);

    auto assignment = ATMUserAssignment(tenantId, userId, request);
    foreach (collectionId; assignment.roleCollectionIds) {
      auto collection = _store.getRoleCollection(tenantId, collectionId);
      if (collection.collectionId.length == 0) {
        throw new ATMNotFoundException("Role collection", tenantId ~ "/" ~ collectionId);
      }
    }
    if (assignment.idpId.length > 0) {
      auto idp = _store.getIdp(tenantId, assignment.idpId);
      if (idp.idpId.length == 0) {
        throw new ATMNotFoundException("Identity provider", tenantId ~ "/" ~ assignment.idpId);
      }
    }

    assignment.updatedAt = Clock.currTime();
    auto saved = _store.upsertUserAssignment(assignment);

    return Json.emptyObject
      .set("success", true)
      .set("assignment", saved.toJson());
  }

  Json getUserAssignments(UUID tenantId, string userId) {
    validateId(tenantId, "Tenant ID");
    validateId(userId, "User ID");
    ensureTenantBootstrapped(tenantId);

    auto assignment = _store.getUserAssignment(tenantId, userId);
    if (assignment.userId.length == 0) {
      throw new ATMNotFoundException("User assignment", tenantId ~ "/" ~ userId);
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("assignment", assignment.toJson());
  }

  ATMSessionContext authenticateBearer(UUID tenantId, string authorizationHeader) {
    validateId(tenantId, "Tenant ID");
    ensureTenantBootstrapped(tenantId);

    if (authorizationHeader.length < 8 || authorizationHeader[0 .. 7] != "Bearer ") {
      throw new ATMAuthorizationException("Missing Bearer token");
    }

    auto token = authorizationHeader[7 .. $].strip();
    if (token.length == 0) {
      throw new ATMAuthorizationException("Bearer token cannot be empty");
    }

    auto parts = token.split(".");
    if (parts.length < 2) {
      throw new ATMAuthorizationException("Invalid JWT format");
    }

    auto header = parseJsonSafe(decodeBase64Url(parts[0]), "JWT header");
    auto claims = parseJsonSafe(decodeBase64Url(parts[1]), "JWT payload");

    auto alg = claimString(header, "alg", "none");
    if (alg.length == 0) {
      alg = "none";
    }
    if (toLower(alg) == "none" && !_config.allowUnsignedTokens) {
      throw new ATMAuthorizationException("Unsigned JWT tokens are not allowed");
    }

    auto issuer = claimString(claims, "iss", "");
    if (issuer.length == 0) {
      throw new ATMAuthorizationException("Token issuer (iss) claim is required");
    }

    auto idp = _store.findIdpByIssuer(tenantId, issuer);
    if (idp.idpId.length == 0) {
      auto defaultIdp = _store.getDefaultIdp(tenantId);
      if (defaultIdp.idpId.length > 0 && defaultIdp.issuer == issuer) {
        idp = defaultIdp;
      }
    }
    if (idp.idpId.length == 0) {
      throw new ATMAuthorizationException("No trusted IdP for issuer: " ~ issuer);
    }
    if (idp.trustedAlgorithms.length > 0 && !idp.trustedAlgorithms.canFind(alg)) {
      throw new ATMAuthorizationException("JWT algorithm not trusted for IdP: " ~ alg);
    }

    auto tokenAudience = claimStringOrFirstArrayEntry(claims, "aud");
    if (idp.audience.length > 0 && tokenAudience.length > 0 && tokenAudience != idp.audience) {
      throw new ATMAuthorizationException("Token audience mismatch");
    }

    if (_config.enforceTokenExpiry) {
      auto exp = claimLong(claims, "exp", 0);
      if (exp <= 0) {
        throw new ATMAuthorizationException("Token exp claim is required");
      }
      auto now = cast(long)Clock.currTime().toUnixTime();
      if (now >= exp) {
        throw new ATMAuthorizationException("Token expired");
      }
    }

    auto userId = claimString(claims, "sub", "");
    if (userId.length == 0) {
      throw new ATMAuthorizationException("Token subject (sub) claim is required");
    }

    auto assignment = _store.getUserAssignment(tenantId, userId);
    auto effectiveCollectionIds = assignment.userId.length > 0 ? assignment.roleCollectionIds.dup
      : [];
    string[] effectiveTechnicalRoles;
    string[] effectivePermissions;

    foreach (collectionId; effectiveCollectionIds) {
      auto collection = _store.getRoleCollection(tenantId, collectionId);
      if (collection.collectionId.length == 0) {
        continue;
      }

      foreach (roleId; collection.technicalRoleIds) {
        if (!effectiveTechnicalRoles.canFind(roleId)) {
          effectiveTechnicalRoles ~= roleId;
        }

        auto role = _store.getTechnicalRole(tenantId, roleId);
        if (role.roleId.length == 0) {
          continue;
        }

        foreach (permission; role.permissions) {
          if (!effectivePermissions.canFind(permission)) {
            effectivePermissions ~= permission;
          }
        }
      }
    }

    auto scopes = readScopeClaims(claims);
    foreach (scopeName; scopes) {
      if (!effectivePermissions.canFind(scopeName)) {
        effectivePermissions ~= scopeName;
      }
    }

    ATMSessionContext context;
    context.tenantId = UUID(tenantId);
    context.userId = userId;
    context.idpId = idp.idpId;
    context.issuer = issuer;
    context.audience = tokenAudience;
    context.email = claimString(claims, "email", "");
    context.groups = claimStringArray(claims, "groups");
    context.scopes = scopes;
    context.roleCollections = effectiveCollectionIds;
    context.technicalRoles = effectiveTechnicalRoles;
    context.permissions = effectivePermissions;
    context.bootstrap = false;
    context.authenticatedAt = Clock.currTime();
    return context;
  }

  Json currentSession(ATMSessionContext context) {
    return Json.emptyObject
      .set("success", true)
      .set("session", context.toJson());
  }

  Json authorizeApplication(UUID tenantId, ATMSessionContext context, string appId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(appId, "Application ID");

    string[] requiredPermissions;
    if ("required_permissions" in request && request["required_permissions"].isArray) {
      requiredPermissions = stringArrayFromJson(request["required_permissions"]);
    }

    bool authorized = true;
    Json missing = Json.emptyArray;
    foreach (permission; requiredPermissions) {
      if (!context.permissions.canFind(permission)) {
        authorized = false;
        missing ~= permission;
      }
    }

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("application_id", appId)
      .set("user_id", context.userId)
      .set("authorized", authorized)
      .set("required_permissions", requiredPermissions.toJson)
      .set("effective_permissions", context.permissions.toJson)
      .set("missing_permissions", missing);
  }

  bool hasPermission(ATMSessionContext context, string permission) {
    return context.bootstrap || context.permissions.canFind(permission);
  }

  ATMSessionContext bootstrapContext(UUID tenantId) {
    ATMSessionContext context;
    context.tenantId = UUID(tenantId);
    context.userId = "bootstrap";
    context.idpId = "bootstrap";
    context.issuer = "bootstrap";
    context.audience = "bootstrap";
    context.bootstrap = true;
    context.authenticatedAt = Clock.currTime();
    context.permissions = [
      "iam.admin", "app.access.admin", "app.access.read", "app.access.write"
    ];
    return context;
  }

  void ensureTenantBootstrapped(UUID tenantId) {
    auto existingDefault = _store.getDefaultIdp(tenantId);
    if (existingDefault.idpId.length > 0) {
      return;
    }

    ATMIdentityProvider idp;
    idp.tenantId = UUID(tenantId);
    idp.idpId = "sap-id-service";
    idp.name = _config.defaultIdpName;
    idp.providerType = "oidc";
    idp.issuer = _config.defaultIdpIssuer;
    idp.audience = _config.defaultIdpAudience;
    idp.description = "Default ID service style identity provider";
    idp.enabled = true;
    idp.isDefault = true;
    idp.trustedAlgorithms = ["RS256", "ES256", "HS256", "none"];
    idp.updatedAt = Clock.currTime();
    _store.upsertIdp(idp);

    if (_store.getTechnicalRole(tenantId, "AuthTrustAdmin").roleId.length == 0) {
      ATMTechnicalRole adminRole;
      adminRole.tenantId = UUID(tenantId);
      adminRole.roleId = "AuthTrustAdmin";
      adminRole.name = "Authorization and Trust Administrator";
      adminRole.description = "Manages IdP trust and role assignments";
      adminRole.permissions = [
        "iam.admin", "app.access.admin", "app.access.read", "app.access.write"
      ];
      adminRole.updatedAt = Clock.currTime();
      _store.upsertTechnicalRole(adminRole);
    }

    if (_store.getRoleCollection(tenantId, "ATMAdmins").collectionId.length == 0) {
      ATMRoleCollection admins;
      admins.tenantId = UUID(tenantId);
      admins.collectionId = "ATMAdmins";
      admins.name = "ATM Administrators";
      admins.description = "Business-level role collection for ATM operators";
      admins.technicalRoleIds = ["AuthTrustAdmin"];
      admins.updatedAt = Clock.currTime();
      _store.upsertRoleCollection(admins);
    }
  }

  private string claimString(Json claims, string key, string fallback) {
    if (!(key in claims)) {
      return fallback;
    }
    if (claims[key].isString) {
      return claims[key].get!string;
    }
    return fallback;
  }

  private string claimStringOrFirstArrayEntry(Json claims, string key) {
    if (!(key in claims)) {
      return "";
    }

    if (claims[key].isString) {
      return claims[key].get!string;
    }

    if (claims[key].isArray) {
      foreach (item; claims[key].toArray) {
        if (item.isString) {
          return item.get!string;
        }
      }
    }
    return "";
  }

  private long claimLong(Json claims, string key, long fallback) {
    if (!(key in claims)) {
      return fallback;
    }
    if (claims[key].isInteger) {
      return claims[key].get!long;
    }
    if (claims[key].isFloat) {
      return cast(long)claims[key].get!double;
    }
    return fallback;
  }

  private string[] claimStringArray(Json claims, string key) {
    if (!(key in claims)) {
      return null;
    }
    if (claims[key].isArray) {
      return stringArrayFromJson(claims[key]);
    }
    return null;
  }

  private string[] readScopeClaims(Json claims) {
    string[] scopes;

    if ("scope" in claims && claims["scope"].isString) {
      auto scopeString = claims["scope"].get!string;
      foreach (scopeName; scopeString.split(" ")) {
        auto trimmed = scopeName.strip();
        if (trimmed.length > 0 && !scopes.canFind(trimmed)) {
          scopes ~= trimmed;
        }
      }
    }

    if ("scp" in claims && claims["scp"].isArray) {
      foreach (scopeName; stringArrayFromJson(claims["scp"])) {
        if (!scopes.canFind(scopeName)) {
          scopes ~= scopeName;
        }
      }
    }

    return scopes;
  }

  private Json parseJsonSafe(string text, string label) {
    try {
      return parseJsonString(text);
    } catch (Exception) {
      throw new ATMAuthorizationException("Invalid " ~ label);
    }
  }

  private string decodeBase64Url(string value) {
    auto normalized = value.replace("-", "+").replace("_", "/");
    auto padding = normalized.length % 4;
    if (padding == 2) {
      normalized ~= "==";
    } else if (padding == 3) {
      normalized ~= "=";
    } else if (padding == 1) {
      throw new ATMAuthorizationException("Invalid base64-url value");
    }

    try {
      auto bytes = Base64.decode(normalized);
      return cast(string)bytes.idup;
    } catch (Exception) {
      throw new ATMAuthorizationException("Invalid base64-url encoding");
    }
  }


}
