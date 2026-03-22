module uim.sap.service.helpers.validate;

import uim.sap.service;

mixin(ShowModule!());

@safe:

bool validateTenant(UUID tenantId) {
  return validateTenant(tenantId.toString);
}

bool validateTenant(string tenantId) {
  return validateId(tenantId, "Tenant ID");
}

bool validateId(UUID value, string fieldName) {
  return validateId(value.toString, fieldName);
}

bool validateId(string value, string fieldName) {
  if (value.length == 0) {
    throw new SAPValidationException(fieldName ~ " cannot be empty");
  }
  return true;
}

bool validateAuth(HTTPServerRequest req, ISAPConfig cfg) {
  if (!cfg.requireAuthToken) {
    return;
  }

  if (!("Authorization" in req.headers)) {
    throw new SAPAuthenticationException("Missing Authorization header");
  }

  auto expected = "Bearer " ~ cfg.authToken;
  if (req.headers["Authorization"] != expected) {
    throw new SAPAuthenticationException("Invalid Authorization token");
  }

  return true;
}
