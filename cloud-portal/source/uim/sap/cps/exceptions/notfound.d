/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.exceptions.notfound;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSNotFoundException : CPSException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
