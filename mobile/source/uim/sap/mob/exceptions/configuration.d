/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mob.exceptions.configuration;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(MOB) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(MOB) " ~ message, file, line, next);
  }
}
///
unittest {
  MOBConfigurationException ex1 = new MOBConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (MOB) Test message");

  MOBConfigurationException ex2 = new MOBConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (MOB) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}