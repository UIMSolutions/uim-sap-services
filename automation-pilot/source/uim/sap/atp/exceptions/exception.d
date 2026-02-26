module uim.sap.atp.exceptions.exception;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPException : Exception {
  this(string msg) {
    super(msg);
  }
}
