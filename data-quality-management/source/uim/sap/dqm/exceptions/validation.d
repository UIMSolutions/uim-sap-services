module uim.sap.dqm.exceptions.validation;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMValidationException : DQMException {
    this(string msg) { super(msg); }
}
