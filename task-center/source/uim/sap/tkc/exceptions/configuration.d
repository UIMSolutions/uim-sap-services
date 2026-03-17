/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.exceptions.configuration;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(TKC) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(TKC) " ~ message, file, line, next);
  }
}
///
unittest {
  TKCConfigurationException ex1 = new TKCConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (TKC) Test message");

  TKCConfigurationException ex2 = new TKCConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (TKC) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}