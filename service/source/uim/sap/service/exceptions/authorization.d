module uim.sap.service.exceptions.authorization;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPAuthorizationException : SAPException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("Unauthorized: " ~ message, file, line, next);
  }
}
