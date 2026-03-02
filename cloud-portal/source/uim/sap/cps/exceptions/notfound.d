module uim.sap.cps.exceptions.notfound;








class CPSNotFoundException : CPSException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
