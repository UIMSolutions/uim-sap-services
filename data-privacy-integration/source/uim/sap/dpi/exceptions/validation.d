module uim.sap.dpi.exceptions.validation;
import uim.sap.dpi;

mixin(ShowModule!());

@safe:
class DPIValidationException : DPIException {
    this(string msg) { super(msg); }
}
