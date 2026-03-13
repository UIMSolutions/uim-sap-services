module uim.sap.prm.exceptions.notfound;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMNotFoundException : PRMException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
