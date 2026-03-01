module uim.sap.ids.exceptions.group;

import uim.sap.ids;
@safe:

/**
 * Exception thrown when a group operation fails
 */
class IdentityGroupException : IdentityException {
    int statusCode;
    
    this(string msg, int code = 0, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe {
        super(msg, file, line, nextInChain);
        this.statusCode = code;
    }
}
