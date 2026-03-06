module uim.sap.mdg.exceptions.exception;

import uim.sap.mdg;
@safe:

/** 
 * Base class for all exceptions in MDG.
 */
class MDGException : SAPException {
    this(string msg) {
        super(msg);
    }
}