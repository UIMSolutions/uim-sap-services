module uim.sap.service.helpers.validate;

import uim.sap.service;

mixin(ShowModule!());

@safe:

void validateTenant(UUID tenantId) {
  validateTenant(tenantId.toString);
}

void validateTenant(string tenantId) {
  validateId(tenantId, "Tenant ID");
}

void validateId(UUID value, string fieldName) {
  validateId(value.toString, fieldName);
}

void validateId(string value, string fieldName) {
  if (value.length == 0) {
    throw new SAPValidationException(fieldName ~ " cannot be empty");
  }
}
