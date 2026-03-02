module uim.sap.cid.exceptions.notfound;

class CIDNotFoundException : CIDException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
