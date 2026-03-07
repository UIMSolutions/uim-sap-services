module uim.sap.dpi.exceptions.authorization;
import uim.sap.dpi;

mixin(ShowModule!());

@safe:
class DPIAuthorizationException : DPIException {
    this(string msg) { super(msg); }
}
