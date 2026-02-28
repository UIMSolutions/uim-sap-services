module uim.sap.aem.exceptions.exception;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


class AEMException : Exception {
    this(string message) {
        super(message);
    }
}
