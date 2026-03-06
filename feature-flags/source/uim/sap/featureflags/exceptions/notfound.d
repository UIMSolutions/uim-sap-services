module uim.sap.featureflags.exceptions.notfound;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLNotFoundException : FFLException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
