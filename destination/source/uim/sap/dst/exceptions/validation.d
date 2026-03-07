module uim.sap.dst.exceptions.validation;
import uim.sap.dst;

mixin(ShowModule!());

@safe:
class DSTValidationException : DSTException {
    this(string msg) { super(msg); }
}
