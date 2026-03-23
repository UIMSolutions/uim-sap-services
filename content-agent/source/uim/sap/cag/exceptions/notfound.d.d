module uim.sap.cag.exceptions.notfound.d;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGNotFoundException : CAGException {
  this(string message) {
    super(message);
  }
}
