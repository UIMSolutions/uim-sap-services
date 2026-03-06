module uim.sap.service.exceptions.exception;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPException : Exception {
    this(string msg) { super(msg); }
}
