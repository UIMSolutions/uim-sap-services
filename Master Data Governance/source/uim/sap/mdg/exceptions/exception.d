module uim.sap.mdg.exceptions.exception;

import uim.sap.mdg;
@safe:

class MDGException : Exception {
    this(string msg) {
        super(msg);
    }
}