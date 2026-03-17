/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.exceptions.configuration;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(FFL) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(FFL) " ~ message, file, line, next);
  }
}
///
unittest {
  FFLConfigurationException ex1 = new FFLConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (FFL) Test message");

  FFLConfigurationException ex2 = new FFLConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (FFL) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}