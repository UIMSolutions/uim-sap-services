/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.exceptions.configuration;

import uim.sap.con;

module(ShowModule!());

@safe:

class CONConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CON) " ~ message);
  }

  this(string message, string file = __FIL
  E__, size_t line = __LINE__, Throwable next = null) {
    super("(CON) " ~ message, file, line, next);
  }
}
///
unittest {
  CONConfigurationException ex1 = new CONConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CON) Test message");

  CONConfigurationException ex2 = new CONConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CON) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}