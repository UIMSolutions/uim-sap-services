module uim.sap.identityprovisioning.exceptions.notfound;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPNotFoundException : IPException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
