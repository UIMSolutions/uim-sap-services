module uim.sap.service.exceptions.exception;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPException : Exception {
  this(string msg) {
    super(msg);
  }

  this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(msg, file, line, next);
  }
}
