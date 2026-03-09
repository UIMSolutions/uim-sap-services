module uim.sap.buh.exceptions.authorization;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHAuthorizationException : BUHException {
  this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(msg, file, line, next);
  }
}