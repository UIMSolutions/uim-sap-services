/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.exceptions.exception;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCException : SAPException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}