module uim.sap.ids.exceptions.validation;

import uim.sap.ids;
@safe:

/**
 * Exception thrown when validation fails
 */
class IdentityValidationException : IdentityException {
    string[] validationErrors;
    
    this(string msg, string[] errors = [], string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe {
        super(msg, file, line, nextInChain);
        this.validationErrors = errors;
    }
}