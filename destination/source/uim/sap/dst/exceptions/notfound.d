module uim.sap.dst.exceptions.notfound;
import uim.sap.dst;

mixin(ShowModule!());

@safe:
class DSTNotFoundException : DSTException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
