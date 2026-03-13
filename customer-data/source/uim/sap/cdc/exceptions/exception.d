module uim.sap.cdc.exceptions.exception;

module uim.sap.cdc.exceptions.exception;

class CDCException : SAPException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}