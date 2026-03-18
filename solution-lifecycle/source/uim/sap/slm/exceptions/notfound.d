module uim.sap.slm.exceptions.notfound;

class SLMNotFoundException : SLMException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
