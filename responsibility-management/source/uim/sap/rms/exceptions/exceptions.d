module uim.sap.rms.exceptions.exceptions;




class RMSNotFoundException : RMSException {
    this(string objectType, string objectId, string file = __FILE__, size_t line = __LINE__) {
        super(objectType ~ " not found: " ~ objectId, file, line);
    }
}

