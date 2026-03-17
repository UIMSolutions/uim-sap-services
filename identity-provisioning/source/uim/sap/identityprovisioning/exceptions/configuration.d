/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.identityprovisioning.exceptions.configuration;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPVConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(IPV) " ~ message);
  }
IPV
  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(IPV) " ~ message, file, line, next);
  }
}
///
unittest {
  IPVConfigurationException ex1 = new IPVConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (IPV) Test message");

  IPVConfigurationException ex2 = new IPVConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (IPV) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}