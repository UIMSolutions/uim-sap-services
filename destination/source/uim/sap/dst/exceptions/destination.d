/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.exceptions.destination;

import uim.sap.dst;

mixin(ShowModule!());

@safe:
/// Thrown for destination-specific operational errors (connectivity, auth flow failure, etc.)
class DSTDestinationException : DSTException {
  this(string msg) {
    super(msg);
  }
}
