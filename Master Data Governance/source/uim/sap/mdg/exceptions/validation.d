module uim.sap.mdg.exceptions.validation;

import uim.sap.mdg;
@safe:

class MDGValidationException : MDGException {
    this(string msg) {
        super(msg);
    }
}