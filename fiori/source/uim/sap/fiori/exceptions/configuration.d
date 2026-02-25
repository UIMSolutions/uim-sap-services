module uim.sap.fiori.exceptions.configuration;

import uim.sap.fiori;
@safe:
class FioriConfigurationException : FioriException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
