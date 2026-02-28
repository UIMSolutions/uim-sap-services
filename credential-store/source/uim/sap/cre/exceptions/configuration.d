module uim.sap.cre.exceptions.configuration;

import uim.sap.cre;

mixin(ShowModule!());

@safe:
class CREConfigurationException : CREException {
  this(string msg) {
    super(msg);
  }
}
