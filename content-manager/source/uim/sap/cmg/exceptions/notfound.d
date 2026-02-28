module uim.sap.cmg.exceptions.notfound;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGNotFoundException : CMGException {
    this(string msg) { super(msg); }
}



