/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.obs.exceptions.configuration;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(OBS) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(OBS) " ~ message, file, line, next);
  }
}
///
unittest {
  OBSConfigurationException ex1 = new OBSConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (OBS) Test message");

  OBSConfigurationException ex2 = new OBSConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (OBS) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}