module uim.sap.kst.exceptions.crypto;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTCryptoException : KSTException {
    this(string msg) {
        super(msg);
    }
}
