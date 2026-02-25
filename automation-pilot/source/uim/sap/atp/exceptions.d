module uim.sap.atp.exceptions;

class ATPException : Exception { this(string msg) { super(msg); } }
class ATPValidationException : ATPException { this(string msg) { super(msg); } }
class ATPNotFoundException : ATPException { this(string msg) { super(msg); } }
class ATPAuthorizationException : ATPException { this(string msg) { super(msg); } }
class ATPConfigurationException : ATPException { this(string msg) { super(msg); } }
