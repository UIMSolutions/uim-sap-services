module uim.sap.service.helpers.contains;

import uim.sap.service;

mixin(ShowModule!());

@safe:

bool containsTenant(string[] values, string tenantId) {
  return values.any!(v => v == tenantId);
}

bool containsTenant(string[] values, UUID tenantId) {
  return values.any!(v => v == tenantId.toString);
}

bool containsTenant(UUID[] ids, UUID tenantId) {
  return ids.any!(id => id == tenantId);
}
