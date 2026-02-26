/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.exceptions.exception;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
  * Base exception class for all Agentry-related exceptions.
  *
  * This class serves as the parent for all specific exceptions in the Agentry module, such as:
  * - `AgentryNotFoundException`
  * - `AgentryValidationException`
  * - `AgentryAuthorizationException`
  * - `AgentryConfigurationException`
  * etc.
  *
  * By catching `AgentryException`, you can handle all Agentry-related errors in a single catch block, while still allowing for more specific handling of individual exception types if needed.
  */
class AgentryException : Exception {
  this(string message) {
    super(message);
  }
}
