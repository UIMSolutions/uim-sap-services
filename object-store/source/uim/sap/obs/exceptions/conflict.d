module uim.sap.obs.exceptions.conflict;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSConflictException : OBSException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " already exists: " ~ id, file, line);
    }
}
