module uim.sap.cre.exceptions.notfound;

class CRENotFoundException : CREException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
