module uim.sap.dqm.exceptions.notfound;


import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMNotFoundException : DQMException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
