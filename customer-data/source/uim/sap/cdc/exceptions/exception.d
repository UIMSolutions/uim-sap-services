module uim.sap.cdc.exceptions.exception;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

class CDCException : SAPException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}