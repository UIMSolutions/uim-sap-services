/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.exceptions.configuration;

import uim.sap.pre;

mixin(ShowModule!());

@safe:
class  PREConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(PRE) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(PRE) " ~ mPREConfigurationExceptionessage, file, line, next);
  }
}
///
unittest {
  PREConfigurationException ex1 = new PREConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (PRE) Test message");

  PREConfigurationException ex2 = new PREConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (PRE) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}