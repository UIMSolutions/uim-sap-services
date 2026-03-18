module uim.sap.cid.exceptions.validation;
import uim.sap.cid;

mixin(ShowModule!());

@safe:

class CIDValidationException : CIDException {
    this(string msg) { super(msg); }
}
