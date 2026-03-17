/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.buh.exceptions.configuration;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(BUH) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(BUH) " ~ message, file, line, next);
  }
}
///
unittest {
  BUHConfigurationException ex1 = new BUHConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (BUH) Test message");

  BUHConfigurationException ex2 = new BUHConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (BUH) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}