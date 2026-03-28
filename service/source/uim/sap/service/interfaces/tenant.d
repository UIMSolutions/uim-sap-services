module uim.sap.service.interfaces.tenant;

import uim.sap.service;

mixin(ShowModule!());

@safe:

interface ISAPTenant : ISAPObject {
  bool isValid();

  bool validate();
}
