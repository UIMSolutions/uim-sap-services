module uim.sap.service.exceptions.validation;
import uim.sap.service;

mixin(ShowModule!());

@safe:
class SAPValidationException : SAPException {
  this(string message) {
    super("Validation error: " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("Validation error: " ~ message, file, line, next);
  }
}