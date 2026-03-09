/**
 * Exceptions for BUH service
 */
module uim.sap.buh.exceptions.notfound;


import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHNotFoundException : BUHException {
  this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(entityType ~ " not found: " ~ id, file, line, next);
  }
}


