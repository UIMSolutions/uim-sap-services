module uim.sap.service.exceptions.validation;
import uim.sap.service;

mixin(ShowModule!());

@safe:
class SAPValidationException : SAPException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}