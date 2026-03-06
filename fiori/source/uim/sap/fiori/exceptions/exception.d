module uim.sap.fiori.exceptions.exception;

import uim.sap.fiori;
@safe:

class FioriException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}