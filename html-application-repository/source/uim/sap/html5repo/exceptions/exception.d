module uim.sap.html5repo.exceptions.exception;

class HTMRepoException : SAPException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class HTMRepoValidationException : HTMRepoException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class HTMRepoAuthorizationException : HTMRepoException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class HTMRepoNotFoundException : HTMRepoException {
    this(string objectType, string objectId, string file = __FILE__, size_t line = __LINE__) {
        super(objectType ~ " not found: " ~ objectId, file, line);
    }
}

class HTMRepoConfigurationException : HTMRepoException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
