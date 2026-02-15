/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.exceptions.authorization;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

// Exception for authorization failures, e.g. insufficient permissions, invalid credentials, etc.
class CLFAuthorizationException : CLFException {
  this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(msg, file, line, next);
  }
}
