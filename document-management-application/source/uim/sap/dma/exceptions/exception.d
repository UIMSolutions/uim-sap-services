module uim.sap.dma.exceptions.exception;

import uim.sap.dma;

mixin(ShowModule!());

@safe:
/// Base exception for all Document Management errors.
class DMAException : SAPException {
    this(string message) {
        super(message);
    }
}