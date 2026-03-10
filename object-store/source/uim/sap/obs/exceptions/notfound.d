module uim.sap.obs.exceptions.notfound;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSNotFoundException : OBSException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " not found: " ~ id, file, line);
    }
}
