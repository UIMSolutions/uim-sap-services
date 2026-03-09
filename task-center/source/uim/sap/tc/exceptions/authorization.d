module uim.sap.tkc.exceptions.authorization;

class TKCAuthorizationException : TKCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}