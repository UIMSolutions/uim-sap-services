/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.exceptions.notfound;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMNotFoundException : AEMException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
