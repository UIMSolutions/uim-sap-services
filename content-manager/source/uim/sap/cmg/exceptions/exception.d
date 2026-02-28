module uim.sap.cmg.exceptions.exception;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGException : Exception {
    this(string msg) { super(msg); }
}