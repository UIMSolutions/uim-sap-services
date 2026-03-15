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
}
///
unittest {
  AASConfigurationException ex = new AASConfigurationException("Test message");
  assert(ex.message == "Configuration error: (AAS) Test message");
}