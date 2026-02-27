module uim.sap.mgt.exceptions.exception;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/**
  * This file defines the MGTException class, which serves as the base exception class for all exceptions in the Management module.
  * It extends the built-in Exception class, allowing it to be used in a consistent way with other exceptions in the module.
  *
  * Example usage:
  * try {
  *     // Some code that may throw an exception
  * } catch (MGTException e) {
  *     // Handle the exception
  * }
  */
class MGTException : Exception {
  this(string msg) {
    super(msg);
  }
}
