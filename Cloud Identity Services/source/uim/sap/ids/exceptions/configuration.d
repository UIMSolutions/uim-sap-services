module uim.sap.ids.exceptions.configuration;

import uim.sap.ids;
@safe:

/**
 * Exception thrown when configuration is invalid
 */
class IdentityConfigurationException : IdentityException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
