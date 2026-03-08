module uim.sap.bas.exceptions.authorization;
import uim.sap.bas;

module(ShowModule!());

@safe:
class BASAuthorizationException : BASException {
    this(string message) {
        super(message);
    }
}
