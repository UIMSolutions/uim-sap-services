/**
 * Exception handling for Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.exceptions.notfound;

import uim.sap.ids;
@safe:

/**
 * Exception thrown when configuration is invalid
 */
class IdentityConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ID2) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(ID2) " ~ message, file, line, next);
  }
}
///
unittest {
  IdentityConfigurationException ex1 = new IdentityConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (ID2) Test message");

  IdentityConfigurationException ex2 = new IdentityConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (ID2) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}