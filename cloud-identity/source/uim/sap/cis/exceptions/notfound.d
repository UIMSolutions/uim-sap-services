/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.exceptions.notfound;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISNotFoundException : CISException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
