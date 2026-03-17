/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.auditlog.exceptions.configuration;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:
class ADLConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ADL) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(ADL) " ~ message, file, line, next);
  }
}
///
unittest {
  ADLConfigurationException ex1 = new ADLConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (ADL) Test message");

  ADLConfigurationException ex2 = new ADLConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (ADL) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}

