module uim.sap.mgt.exceptions.configuration;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/**
  * This file defines the MGTConfigurationException class, which is used to represent exceptions related to configuration issues in the SAP Management module.
  * It extends the MGTException class, allowing it to be used in a consistent way with other exceptions in the module.
  *
  * Example usage:
  * try {
  *     // Code that may throw a configuration exception
  * } catch (MGTConfigurationException e) {
  *     // Handle configuration error
  * }
  */
class MGTConfigurationException : MGTException {
  this(string msg) {
    super(msg);
  }
}
