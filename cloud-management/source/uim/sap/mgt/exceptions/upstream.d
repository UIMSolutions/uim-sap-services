module uim.sap.mgt.exceptions.upstream;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/** 
  * Base exception for all upstream errors in MGT. 
  * This can be used to catch any unexpected errors from upstream services.
  *
  * Note: This is a general exception and should be used for unforeseen issues.
  * For specific known error scenarios, consider creating more specific exceptions.
  *
  * Example usage:
  * try {
  *     // Call to an upstream service
  * } catch (MGTUpstreamException e) {
  *     // Handle upstream error
  * }
  */
class MGTUpstreamException:
MGTException {
  this(string msg) {
    super(msg);
  }
}
