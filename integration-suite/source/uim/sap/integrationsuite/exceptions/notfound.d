module uim.sap.integrationsuite.exceptions.notfound;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISNotFoundException : ISException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
