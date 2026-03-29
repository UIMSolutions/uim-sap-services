module uim.sap.service.interfaces.tenant;

import uim.sap.service;

mixin(ShowModule!());

@safe:

interface ISAPTenant : ISAPEntity {
  bool isValid();

  bool validate();
}
