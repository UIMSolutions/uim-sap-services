module uim.sap.atm.service;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMService : SAPService {
    private ATMConfig _config;
    private ATMStore _store;

    this(ATMConfig config) {
        config.validate();
        _config = config;
        _store = new ATMStore;
    }

    @property const(ATMConfig) config() const {
        return _config;
    }

    Json health() {
        Json result = Json.emptyObject;
        result["ok"] = true;
        result["serviceName"] = _config.serviceName;
        result["serviceVersion"] = _config.serviceVersion;
        return result;
    }

    Json ready() {
        Json result = Json.emptyObject;
        result["ready"] = true;
        result["timestamp"] = Clock.currTime().toISOExtString();
        return result;
    }

    Json upsertIdentityProvider(string tenantId, string idpId, Json request) {
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

        Json result = Json.emptyObject;
        result["success"] = true;
        result["identity_provider"] = saved.toJson();
        return result;
    }

    Json listIdentityProviders(string tenantId) {
        validateId(tenantId, "Tenant ID");
        ensureTenantBootstrapped(tenantId);

        Json resources = Json.emptyArray;
        foreach (idp; _store.listIdps(tenantId)) {
            resources ~= idp.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long)resources.length;
        return result;
    }

    Json setDefaultIdentityProvider(string tenantId, string idpId) {
        validateId(tenantId, "Tenant ID");
        validateId(idpId, "Identity provider ID");
        ensureTenantBootstrapped(tenantId);

        auto idp = _store.setDefaultIdp(tenantId, idpId);
        if (idp.idpId.length == 0) {
            throw new ATMNotFoundException("Identity provider", tenantId ~ "/" ~ idpId);
        }

        Json result = Json.emptyObject;
        result["success"] = true;
        result["identity_provider"] = idp.toJson();
        return result;
    }

    Json upsertTechnicalRole(string tenantId, string roleId, Json request) {
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

        Json result = Json.emptyObject;
        result["success"] = true;
        result["technical_role"] = saved.toJson();
        return result;
    }

    Json listTechnicalRoles(string tenantId) {
        validateId(tenantId, "Tenant ID");
        ensureTenantBootstrapped(tenantId);

        Json resources = Json.emptyArray;
        foreach (role; _store.listTechnicalRoles(tenantId)) {
            resources ~= role.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long)resources.length;
        return result;
    }

    Json upsertRoleCollection(string tenantId, string collectionId, Json request) {
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

        Json result = Json.emptyObject;
        result["success"] = true;
        result["role_collection"] = saved.toJson();
        return result;
    }

    Json listRoleCollections(string tenantId) {
        validateId(tenantId, "Tenant ID");
        ensureTenantBootstrapped(tenantId);

        Json resources = Json.emptyArray;
        foreach (collection; _store.listRoleCollections(tenantId)) {
            resources ~= collection.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long)resources.length;
        return result;
    }

    Json upsertUserAssignments(string tenantId, string userId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(userId, "User ID");
        ensureTenantBootstrapped(tenantId);

        auto assignment = userAssignmentFromJson(tenantId, userId, request);
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

        Json result = Json.emptyObject;
        result["success"] = true;
        result["assignment"] = saved.toJson();
        return result;
    }

    Json getUserAssignments(string tenantId, string userId) {
        validateId(tenantId, "Tenant ID");
        validateId(userId, "User ID");
        ensureTenantBootstrapped(tenantId);

        auto assignment = _store.getUserAssignment(tenantId, userId);
        if (assignment.userId.length == 0) {
            throw new ATMNotFoundException("User assignment", tenantId ~ "/" ~ userId);
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["assignment"] = assignment.toJson();
        return result;
    }

    ATMSessionContext authenticateBearer(string tenantId, string authorizationHeader) {
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
        auto effectiveCollectionIds = assignment.userId.length > 0 ? assignment.roleCollectionIds.dup : [];
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
        context.tenantId = tenantId;
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
        Json result = Json.emptyObject;
        result["success"] = true;
        result["session"] = context.toJson();
        return result;
    }

    Json authorizeApplication(string tenantId, ATMSessionContext context, string appId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(appId, "Application ID");

        string[] requiredPermissions;
        if ("required_permissions" in request && request["required_permissions"].type == Json.Type.array) {
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

        Json result = Json.emptyObject;
        result["success"] = true;
        result["tenant_id"] = tenantId;
        result["application_id"] = appId;
        result["user_id"] = context.userId;
        result["authorized"] = authorized;
        result["required_permissions"] = requiredPermissions.toJson;
        result["effective_permissions"] = context.permissions.toJson;
        result["missing_permissions"] = missing;
        return result;
    }

    bool hasPermission(ATMSessionContext context, string permission) {
        return context.bootstrap || context.permissions.canFind(permission);
    }

    ATMSessionContext bootstrapContext(string tenantId) {
        ATMSessionContext context;
        context.tenantId = tenantId;
        context.userId = "bootstrap";
        context.idpId = "bootstrap";
        context.issuer = "bootstrap";
        context.audience = "bootstrap";
        context.bootstrap = true;
        context.authenticatedAt = Clock.currTime();
        context.permissions = ["iam.admin", "app.access.admin", "app.access.read", "app.access.write"];
        return context;
    }

    void ensureTenantBootstrapped(string tenantId) {
        auto existingDefault = _store.getDefaultIdp(tenantId);
        if (existingDefault.idpId.length > 0) {
            return;
        }

        ATMIdentityProvider idp;
        idp.tenantId = tenantId;
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
            adminRole.tenantId = tenantId;
            adminRole.roleId = "AuthTrustAdmin";
            adminRole.name = "Authorization and Trust Administrator";
            adminRole.description = "Manages IdP trust and role assignments";
            adminRole.permissions = ["iam.admin", "app.access.admin", "app.access.read", "app.access.write"];
            adminRole.updatedAt = Clock.currTime();
            _store.upsertTechnicalRole(adminRole);
        }

        if (_store.getRoleCollection(tenantId, "ATMAdmins").collectionId.length == 0) {
            ATMRoleCollection admins;
            admins.tenantId = tenantId;
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

        if (claims[key].type == Json.Type.array) {
            foreach (item; claims[key].get!(Json[])) {
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
            return [];
        }
        if (claims[key].type == Json.Type.array) {
            return stringArrayFromJson(claims[key]);
        }
        return [];
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

        if ("scp" in claims && claims["scp"].type == Json.Type.array) {
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

    private void validateId(string value, string fieldName) {
        if (value.length == 0) {
            throw new ATMValidationException(fieldName ~ " cannot be empty");
        }
    }
}
