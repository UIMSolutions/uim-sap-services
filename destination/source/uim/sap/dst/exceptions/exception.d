module uim.sap.dst.exceptions.exception;
import uim.sap.dst;

mixin(ShowModule!());

@safe:
class DSTException : SAPException {
    this(string msg) {
        super(msg);
    }
}
