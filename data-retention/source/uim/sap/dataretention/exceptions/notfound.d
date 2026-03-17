module uim.sap.dataretention.exceptions.notfound;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMNotFoundException : DRMException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
