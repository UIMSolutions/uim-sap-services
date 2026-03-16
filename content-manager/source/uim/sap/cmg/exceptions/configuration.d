/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.exceptions.configuration;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CMG) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CMG) " ~ message, file, line, next);
  }
}
///
unittest {
  CMGConfigurationException ex1 = new CMGConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CMG) Test message");

  CMGConfigurationException ex2 = new CMGConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CMG) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}