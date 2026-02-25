module uim.sap.dqm.exceptions.notfound;







class DQMNotFoundException : DQMException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
