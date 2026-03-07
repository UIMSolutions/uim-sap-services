module uim.sap.dqm.exceptions.configuration;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMConfigurationException : DQMException {
    this(string msg) { super(msg); }
}