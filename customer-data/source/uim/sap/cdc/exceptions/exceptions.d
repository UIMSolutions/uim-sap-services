module uim.sap.cdc.exceptions.exceptions;

class CDCException : SAPException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}

class CDCValidationException : CDCException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}

class CDCAuthorizationException : CDCException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}

class CDCNotFoundException : CDCException {
  this(string objectType, string objectId, string file = __FILE__, size_t line = __LINE__) {
    super(objectType ~ " not found: " ~ objectId, file, line);
  }
}

class CDCConfigurationException : CDCException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}

class CDCStoreException : CDCException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}
