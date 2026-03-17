/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.exceptions.configuration;

import uim.sap.aas;
@safe:

class AASConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(AAS) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(AAS) " ~ message, file, line, next);
  }
}
///
unittest {
  AASConfigurationException ex1 = new AASConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (AAS) Test message");

  AASConfigurationException ex2 = new AASConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (AAS) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}