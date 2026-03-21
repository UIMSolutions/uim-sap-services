module uim.sap.cia.exceptions.notfound;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

class CIANotFoundException : CIAException {
    this(string message) { super(message); }
}