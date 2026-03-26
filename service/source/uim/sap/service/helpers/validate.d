module uim.sap.service.helpers.validate;

import uim.sap.service;

mixin(ShowModule!());

@safe:

bool validateTenant(string tenantId) {
  if (tenantId.length == 0) {
    throw new SAPValidationException("Tenant ID cannot be empty");
  }

  return validateTenant(UUID(tenantId));
}

bool validateTenant(UUID tenantId) {
  return validateId(tenantId, "Tenant ID");
}

bool validateId(string value, string fieldName) {
  if (value.length == 0) {
    throw new SAPValidationException(fieldName ~ " cannot be empty");
  }
  return true;
}

bool validateId(UUID value, string fieldName) {
  if (value == NULLUUID) {
    throw new SAPValidationException(fieldName ~ " should be a valid UUID");
  }
  return true;
}
/**
  * Validates the Authorization header in the request against the expected token in the config.
  * If the config does not require an auth token, this function does nothing.
  * Throws SAPAuthorizationException if validation fails.
  */
bool validateAuth(HTTPServerRequest req, ISAPConfig cfg) {
  if (!cfg.requireAuthToken) {
    return true; // No auth required, allow all requests
  }

  if (!("Authorization" in req.headers)) { // Missing header
    throw new SAPAuthorizationException("Missing Authorization header");
  }

  auto expected = "Bearer " ~ cfg.authToken;
  if (req.headers["Authorization"] != expected) { // Invalid token
    throw new SAPAuthorizationException("Invalid Authorization token");
  }

  // Auth is valid
  return true;
}

  // private void validateAuth(HTTPServerRequest req) {
  //   if (!_service.config.requireAuthToken)
  //     return;
  //   auto authHeader = req.headers.get("Authorization", "");
  //   if (!authHeader.startsWith("Bearer "))
  //     throw new PDMAuthorizationException("Missing bearer token");
  //   auto token = authHeader[7 .. $];
  //   if (token != _service.config.authToken)
  //     throw new PDMAuthorizationException("Invalid bearer token");
  // }
