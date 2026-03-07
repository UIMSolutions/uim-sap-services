module uim.sap.dpi.exceptions.notfound;
import uim.sap.dpi;

mixin(ShowModule!());

@safe:
class DPINotFoundException : DPIException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
