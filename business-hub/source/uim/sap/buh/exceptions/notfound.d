/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.buh.exceptions.notfound;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHNotFoundException : BUHException {
  this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(entityType ~ " not found: " ~ id, file, line, next);
  }
}


