/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.exceptions.configuration;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Exception for configuration errors in Datasphere.
  *
  * This exception is thrown when there are issues with the configuration of Datasphere components, such as invalid settings or missing required parameters.
  *
  * Example usage:
  * ```
  * if (configValue is invalid) {
  *     throw new DatasphereConfigurationException("Invalid configuration value: " ~ configValue);
  * }
  * ```
  */
class DatasphereConfigurationException : DatasphereException {
  this(string msg) {
    super(msg);
  }
}
