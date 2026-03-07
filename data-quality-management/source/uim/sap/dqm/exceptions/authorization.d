module uim.sap.dqm.exceptions.authorization;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMAuthorizationException : DQMException {
    this(string msg) { super(msg); }
}