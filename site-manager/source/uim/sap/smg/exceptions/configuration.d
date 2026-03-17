/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.exceptions.configuration;

import uim.sap.smg;

mixin(ShowModule!());

@safe:
/** 
  * Exception thrown when there is a configuration error in the Site Manager.
  *
  * This could be due to missing or invalid configuration values, or issues with loading configuration files.
  *
  * Example usage:
  * try {
  *     // Code that may throw a configuration exception
  * } catch (SMGConfigurationException ex) {
  *     // Handle the configuration error
  * }
  */
class SMGConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(SMG) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(SMG) " ~ message, file, line, next);
  }
}
///
unittest {
  SMGConfigurationException ex1 = new SMGConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (SMG) Test message");

  SMGConfigurationException ex2 = new SMGConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (SMG) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}