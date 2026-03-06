/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.exceptions.authorization;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:
class DatasphereAuthorizationException : DatasphereException {
    this(string msg) { super(msg); }
}
