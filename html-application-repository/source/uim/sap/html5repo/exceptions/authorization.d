module uim.sap.har.exceptions.authorization;

class HARAuthorizationException : HARException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}
