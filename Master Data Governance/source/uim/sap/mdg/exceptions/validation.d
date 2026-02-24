module uim.sap.mdg.exceptions.validation;

import uim.sap.mdg;
@safe:

/** 
 * Exception thrown when validation of data fails.
 */
class MDGValidationException : MDGException {
    this(string msg) {
        super(msg);
    }
}