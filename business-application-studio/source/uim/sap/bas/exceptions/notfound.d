module uim.sap.bas.exceptions.notfound;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASNotFoundException : BASException {
  this(string message) {
    super(message);
  }
}
