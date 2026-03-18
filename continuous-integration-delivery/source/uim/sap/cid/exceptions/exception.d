module uim.sap.cid.exceptions.exception;
import uim.sap.cid;

mixin(ShowModule!());

@safe:

class CIDException : SAPException {
    this(string msg) {
        super(msg);
    }
}
