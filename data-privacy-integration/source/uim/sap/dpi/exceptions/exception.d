module uim.sap.dpi.exceptions.exception;
import uim.sap.dpi;

mixin(ShowModule!());

@safe:
class DPIException : SAPException {
    this(string msg) { super(msg); }
}
