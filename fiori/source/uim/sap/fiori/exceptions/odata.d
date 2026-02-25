module uim.sap.fiori.exceptions.odata;

import uim.sap.fiori;
@safe:

class ODataException : FioriException {
    int statusCode;
    string odataError;
    
    this(string msg, int code = 0, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe {
        super(msg, file, line, nextInChain);
        this.statusCode = code;
    }
}