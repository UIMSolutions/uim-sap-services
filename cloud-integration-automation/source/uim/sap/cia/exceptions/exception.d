module uim.sap.cia.exceptions.exception;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

/// Base exception for all CIA service errors
class CIAException : SAPException {
    this(string message) { super(message); }
}
