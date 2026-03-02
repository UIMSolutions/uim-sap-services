module uim.sap.dst.exceptions.notfound;

class DSTNotFoundException : DSTException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
