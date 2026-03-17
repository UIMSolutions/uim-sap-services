module uim.sap.usagedatamanagement.exceptions.notfound;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMNotFoundException : UDMException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
