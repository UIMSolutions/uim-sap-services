/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.exceptions.configuration;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CPS) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CPS) " ~ message, file, line, next);
  }
}
///
unittest {
  CPSConfigurationException ex1 = new CPSConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CPS) Test message");

  CPSConfigurationException ex2 = new CPSConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CPS) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}