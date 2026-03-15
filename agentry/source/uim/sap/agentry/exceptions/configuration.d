/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.exceptions.configuration;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/** 
  * Exception thrown when there is a configuration error in the Agentry server setup.
  * This can include missing required configuration parameters, invalid values, or incompatible settings.
  *
  * Example usage:
  * ```
  * throw new AgentryConfigurationException("Missing required parameter: serverPort");
  * ```
  *
  * This exception should be used to indicate issues that prevent the Agentry server from starting or functioning correctly due to misconfiguration.  
  * It can be caught and handled to provide feedback to the user or to log configuration issues for troubleshooting.
  */  
class AGTConfigurationException : AgentryException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}