/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.exceptions.validation;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

class AgentryValidationException : AgentryException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}