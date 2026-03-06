module uim.sap.dpi.exceptions.notfound;

class DPINotFoundException : DPIException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
