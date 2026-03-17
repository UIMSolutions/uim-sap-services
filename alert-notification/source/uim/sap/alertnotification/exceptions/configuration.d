/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.exceptions.configuration;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ANO) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(ANO) " ~ message, file, line, next);
  }
}
///
unittest {
  AlertNotificationConfigurationException ex1 = new AlertNotificationConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (ANO) Test message");

  AlertNotificationConfigurationException ex2 = new AlertNotificationConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (ANO) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}

