module uim.sap.rms.exceptions.validation;

class RMSValidationException : RMSException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
