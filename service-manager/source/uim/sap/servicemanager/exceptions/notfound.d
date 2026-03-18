module uim.sap.servicemanager.exceptions.notfound;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMNotFoundException : SVMException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
