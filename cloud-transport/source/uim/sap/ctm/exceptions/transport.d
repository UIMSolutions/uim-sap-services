module uim.sap.ctm.exceptions.transport;

/// Thrown when a transport state transition is illegal
class CTMTransportStateException : CTMException {
    this(string msg) { super(msg); }
}
