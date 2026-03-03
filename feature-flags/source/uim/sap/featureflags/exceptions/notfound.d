module uim.sap.featureflags.exceptions.notfound;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFNotFoundException : FFException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
