module uim.sap.mob.exceptions.conflict;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBConflictException : MOBException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " already exists: " ~ id, file, line);
    }
}
