module uim.sap.ctm.exceptions.transport;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

/// Thrown when a transport state transition is illegal
class CTMTransportStateException : CTMException {
    this(string msg) { super(msg); }
}
