module uim.sap.buh.exceptions.validation;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHValidationException : BUHException {
  this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(msg, file, line, next);
  }
}