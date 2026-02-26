/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.exceptions.authorization;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

/** 
    * Exception thrown when a user is not authorized to perform an action.
    *
    * This could be due to insufficient permissions, invalid credentials, or other authorization issues.
    * 
    * Example usage:
    * try {
    *     // Code that may throw an authorization exception
    * } catch (SMGAuthorizationException ex) {
    *     // Handle the authorization error
    * }
    */
class SMGAuthorizationException : SMGException {
    this(string msg) {
        super(msg);
    }
}
