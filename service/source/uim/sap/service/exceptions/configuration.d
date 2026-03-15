module uim.sap.service.exceptions.configuration;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPConfigurationException : SAPException {
  this(string message) {
    super("Configuration error: " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("Configuration error: " ~ message, file, line, next);
  }
}
