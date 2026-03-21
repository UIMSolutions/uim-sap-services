module uim.sap.cia.exceptions.authorization;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

class CIAAuthorizationException : CIAException {
    this(string message) { super(message); }
}