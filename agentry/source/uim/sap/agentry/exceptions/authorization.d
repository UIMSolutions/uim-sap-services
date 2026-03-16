/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.exceptions.authorization;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
  * Exception thrown when an authorization error occurs, such as invalid credentials or insufficient permissions.
  *
  * This exception indicates that the user or system does not have the necessary permissions to perform the requested action.
  * It can be used to signal issues related to authentication, access control, or any scenario where authorization checks fail.
  * 
  * Example usage:
  * ```
  * if (!user.isAuthenticated()) {
  *     throw new AgentryAuthorizationException("User is not authenticated");
  * }
  * if (!user.hasPermission("admin")) {
  *     throw new AgentryAuthorizationException("User does not have admin permissions");
  * }
  * ```
  * This exception should be caught and handled to provide appropriate feedback to the user, such as prompting for login or displaying an access denied message. It can also be logged for security auditing purposes.
  */
class AGTAuthorizationException : AGTException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
