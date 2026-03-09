module uim.sap.tkc.exceptions.store;

class TKCStoreException : TKCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
