/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.exceptions.configuration;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(INT) " ~ message);
  }
IPV
  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(INT) " ~ message, file, line, next);
  }
}
///
unittest {
  INTConfigurationException ex1 = new INTConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (INT) Test message");

  INTConfigurationException ex2 = new INTConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (INT) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}