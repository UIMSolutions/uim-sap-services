module uim.sap.con.exceptions.notfound;







class CONNotFoundException : CONException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
