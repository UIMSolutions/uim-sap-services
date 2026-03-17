/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.exceptions.configuration;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

// Exception for configuration errors, e.g. invalid configuration values, missing required configuration, etc.
class CLFConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CLF) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CLF) " ~ message, file, line, next);
  }
}
///
unittest {
  CLFConfigurationException ex1 = new CLFConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CLF) Test message");

  CLFConfigurationException ex2 = new CLFConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CLF) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}