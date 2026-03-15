/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.exceptions.configuration;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(AEM) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(AEM) " ~ message, file, line, next);
  }
}
///
unittest {
  AEMConfigurationException ex1 = new AEMConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (AEM) Test message");

  AEMConfigurationException ex2 = new AEMConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (AEM) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}