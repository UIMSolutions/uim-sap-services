module uim.sap.cia.exceptions.validation;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

class CIAValidationException : CIAException {
    this(string message) { super(message); }
}
