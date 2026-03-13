/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.auditlog.exceptions.validation;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:
class AuditLogValidationException : AuditLogException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}