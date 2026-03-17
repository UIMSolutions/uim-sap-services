/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.exceptions.configuration;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(PDM) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(PDM) " ~ message, file, line, next);
  }
}
///
unittest {
  PDMConfigurationException ex1 = new PDMConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (PDM) Test message");

  PDMConfigurationException ex2 = new PDMConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (PDM) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}