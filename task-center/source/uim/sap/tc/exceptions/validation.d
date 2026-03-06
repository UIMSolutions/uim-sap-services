module uim.sap.tkc.exceptions.validation;

class TCValidationException : TCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}