/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mob.exceptions.conflict;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBConflictException : MOBException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " already exists: " ~ id, file, line);
    }
}
