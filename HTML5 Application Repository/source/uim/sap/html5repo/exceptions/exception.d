module uim.sap.html5repo.exceptions.exception;

class HTML5RepoException : Exception {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class HTML5RepoValidationException : HTML5RepoException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class HTML5RepoAuthorizationException : HTML5RepoException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}

class HTML5RepoNotFoundException : HTML5RepoException {
    this(string objectType, string objectId, string file = __FILE__, size_t line = __LINE__) {
        super(objectType ~ " not found: " ~ objectId, file, line);
    }
}

class HTML5RepoConfigurationException : HTML5RepoException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
