/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.exceptions.configuration;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

class CLGConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CLG) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CLG) " ~ message, file, line, next);
  }
}
///
unittest {
  CLGConfigurationException ex1 = new CLGConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CLG) Test message");

  CLGConfigurationException ex2 = new CLGConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CLG) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}