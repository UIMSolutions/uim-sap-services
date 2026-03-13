/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.exceptions.execution;

import uim.sap.art;

mixin(ShowModule!());

@safe:

/**
 * Exception thrown during execution of an ART runtime component.
 *
  * @since 1.0.0
  * @author Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
 */
class ARTRuntimeExecutionException : ARTRuntimeException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}