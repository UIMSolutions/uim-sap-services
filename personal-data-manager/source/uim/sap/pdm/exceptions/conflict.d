module uim.sap.pdm.exceptions.conflict;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMConflictException : PDMException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " already exists: " ~ id, file, line);
    }
}
