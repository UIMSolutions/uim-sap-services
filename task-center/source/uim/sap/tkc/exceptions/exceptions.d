module uim.sap.tkc.exceptions.exceptions;







class TKCNotFoundException : TKCException {
    this(string objectType, string objectId, string file = __FILE__, size_t line = __LINE__) {
        super(objectType ~ " not found: " ~ objectId, file, line);
    }
}

