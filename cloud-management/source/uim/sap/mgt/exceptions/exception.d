module uim.sap.mgt.exceptions.exception;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

class MGTException : Exception {
    this(string msg) {
        super(msg);
    }
}
