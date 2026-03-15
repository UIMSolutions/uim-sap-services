/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.exceptions.configuration;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

// Exception for configuration errors, e.g. invalid configuration values, missing required configuration, etc.
class CLFConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CLF) " ~ message);
  }
}
///
unittest {
  CLFConfigurationException ex = new CLFConfigurationException("Test message");
  assert(ex.message == "Configuration error: (CLF) Test message");
}