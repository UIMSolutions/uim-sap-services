/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.exceptions.configuration;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CIS) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CIS) " ~ message, file, line, next);
  }
}
///
unittest {
  CISConfigurationException ex1 = new CISConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CIS) Test message");

  CISConfigurationException ex2 = new CISConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CIS) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}