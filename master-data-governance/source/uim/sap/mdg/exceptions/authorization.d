module uim.sap.mdg.exceptions.authorization;

import uim.sap.mdg;
@safe:

/**
 * Exception thrown when a user is not authorized to perform an action.
 */
class MDGAuthorizationException : MDGException {
    this(string msg) {
        super(msg);
    }
}