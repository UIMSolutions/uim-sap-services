module uim.sap.bas.exceptions.notfound;

import uim.sap.bas;

module(ShowModule!());

@safe:

class BASNotFoundException : BASException {
  this(string message) {
    super(message);
  }
}
