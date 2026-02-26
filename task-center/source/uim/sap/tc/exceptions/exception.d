module uim.sap.tc.exceptions.exception;

class TCException : Exception {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class TCValidationException : TCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class TCAuthorizationException : TCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class TCNotFoundException : TCException {
    this(string objectType, string objectId, string file = __FILE__, size_t line = __LINE__) {
        super(objectType ~ " not found: " ~ objectId, file, line);
    }
}

class TCConfigurationException : TCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class TCStoreException : TCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
