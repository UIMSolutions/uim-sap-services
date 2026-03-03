module uim.sap.eventmesh.exceptions.notfound;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMNotFoundException : EMException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
