module uim.sap.cis.exceptions.notfound;

class CISNotFoundException : CISException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
