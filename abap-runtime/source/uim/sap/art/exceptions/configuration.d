/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.exceptions.configuration;

import uim.sap.art;

mixin(ShowModule!());

@safe:


class ARTRuntimeConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ART) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(ART) " ~ message, file, line, next);
  }
}
///
unittest {
  ARTRuntimeConfigurationException ex1 = new ARTRuntimeConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (ART) Test message");

  ARTRuntimeConfigurationException ex2 = new ARTRuntimeConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (ART) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}