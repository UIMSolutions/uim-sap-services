/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.exceptions.notfound;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
  * Exception thrown when a requested resource is not found in the Agentry module.
  *
  * This can occur in various scenarios, such as:
  * - A requested entity (e.g., user, configuration, data record) does not exist.
  * - An API endpoint is accessed with an identifier that does not correspond to any existing resource.
  *
  * By catching `AgentryNotFoundException`, you can handle cases where resources are missing and provide appropriate feedback to the user or take corrective actions.
  *
  * Example usage:
  * ```
  * auto user = userService.getUserById(userId);
  * if (user is null) {
  *     throw new AgentryNotFoundException("User", userId);
  * }
  * ```
  * In this example, if the user with the specified ID is not found, an `AgentryNotFoundException` is thrown, indicating that the user resource could not be located.
  *
  * This exception should be caught and handled to inform the user about the missing resource, such as displaying a "Not Found" message or redirecting to an appropriate page. It can also be logged for debugging and auditing purposes.
  *
  * Note: The `resource` parameter in the constructor should be a descriptive name of the type of resource that was not found (e.g., "User", "Configuration", "Data Record"), while the `identifier` parameter should provide specific details about the missing resource (e.g., the ID or name that was used to search for it).
  */
class AGTNotFoundException : AgentryException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}




