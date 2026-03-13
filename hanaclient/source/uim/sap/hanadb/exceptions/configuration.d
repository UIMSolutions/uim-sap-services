module uim.sap.hanadb.exceptions.configuration;

class HanaDBConfigurationException : HanaDBException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}