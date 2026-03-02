module uim.sap.rms.exceptions.authorization;

class RMSAuthorizationException : RMSException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
