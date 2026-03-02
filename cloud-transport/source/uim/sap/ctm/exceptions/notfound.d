module uim.sap.ctm.exceptions.notfound;

class CTMNotFoundException : CTMException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
