module uim.sap.cpi.exceptions.request;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

class CPIRequestException : CPIException {
  int statusCode;

  this(
    string msg,
    int statusCode = 0,
    string file = __FILE__,
    size_t line = __LINE__,
    Throwable next = null
  ) pure nothrow @safe {
    super(msg, file, line, next);
    this.statusCode = statusCode;
  }
}
