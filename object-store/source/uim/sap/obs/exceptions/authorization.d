/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.obs.exceptions.authorization;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSAuthorizationException : OBSException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Authorization failed: " ~ msg, file, line);
    }
}
