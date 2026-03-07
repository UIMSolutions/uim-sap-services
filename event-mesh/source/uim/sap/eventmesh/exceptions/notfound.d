module uim.sap.eventmesh.exceptions.notfound;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMNotFoundException : EVMException {
  this(string resource, string identifier) {
    super(resource ~ " not found: " ~ identifier);
  }
}
