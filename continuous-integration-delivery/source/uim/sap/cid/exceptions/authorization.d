module uim.sap.cid.exceptions.authorization;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

class CIDAuthorizationException : CIDException {
    this(string msg) { super(msg); }
}
