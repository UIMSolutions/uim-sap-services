/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.slm.exceptions.configuration;

import uim.sap.slm;

mixin(ShowModule!());

@safe:

class SLMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(SLM) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(SLM) " ~ message, file, line, next);
  }
}
///
unittest {
  SLMConfigurationException ex1 = new SLMConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (SLM) Test message");

  SLMConfigurationException ex2 = new SLMConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (SLM) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}
