module uim.sap.dqm.exceptions.exception;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMException : SAPException {
    this(string msg) { super(msg); }
}
