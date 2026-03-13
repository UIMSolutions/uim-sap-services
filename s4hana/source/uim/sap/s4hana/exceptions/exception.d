module uim.sap.s4hana.exceptions.exception;
import uim.sap.s4hana;

mixin(ShowModule!());

@safe:
class S4HANAException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}