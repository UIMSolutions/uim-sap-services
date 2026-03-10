/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.exceptions.quota;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMQuotaExceededException : PDMException {
    this(string resource, size_t limit, string file = __FILE__, size_t line = __LINE__) {
        import std.conv : to;
        super("Quota exceeded for " ~ resource ~ ": maximum " ~ limit.to!string, file, line);
    }
}
