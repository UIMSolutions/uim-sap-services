/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.exceptions.validation;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/** 
  * Exception thrown when validation of input data fails in the Agentry module.
  *
  * This exception should be used to indicate that the provided data does not meet the required criteria for processing, such as missing required fields, invalid formats, or values that are out of acceptable ranges.
  *
  * By throwing an `AgentryValidationException`, you can provide a clear and specific error message that helps identify the cause of the validation failure, allowing for easier debugging and user feedback.
  *
  * Example usage:
  * ```
  * if (inputData.username.length == 0) {
  *     throw new AgentryValidationException("Username is required");
  * }
  * if (inputData.age < 0) {
  *     throw new AgentryValidationException("Age cannot be negative");
  * }
  * ```
  * In this example, if the username is missing or the age is negative, an `AgentryValidationException` is thrown with a descriptive message indicating the specific validation issue.
  * This exception should be caught and handled to inform the user about the validation errors, such as displaying error messages next to the relevant input fields or providing a summary of validation issues. It can also be logged for debugging and auditing purposes.
  *
  * Note: The `message` parameter in the constructor should provide a clear and concise description of the validation error, ideally indicating which field or value caused the failure and what the expected criteria were.
  */
class AgentryValidationException : AgentryException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}