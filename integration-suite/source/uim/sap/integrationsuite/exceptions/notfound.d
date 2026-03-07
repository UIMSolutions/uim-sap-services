/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.exceptions.notfound;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISNotFoundException : ISException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
