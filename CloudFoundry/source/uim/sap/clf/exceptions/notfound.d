/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.exceptions.notfound;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

// Exception for not found entities, e.g. missing configuration, missing user, etc.
class CLFNotFoundException : CLFException {
  this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(entityType ~ " not found: " ~ id, file, line, next);
  }
}
