module uim.sap.mgt.exceptions.exceptions;




class MGTAuthorizationException : MGTException {
    this(string msg) {
        super(msg);
    }
}

class MGTUpstreamException : MGTException {
    this(string msg) {
        super(msg);
    }
}
