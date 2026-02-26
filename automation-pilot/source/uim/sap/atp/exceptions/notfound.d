module uim.sap.atp.exceptions.notfound;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPNotFoundException : ATPException {
  this(string msg) {
    super(msg);
  }
}
