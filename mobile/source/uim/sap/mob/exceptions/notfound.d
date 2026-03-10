module uim.sap.mob.exceptions.notfound;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBNotFoundException : MOBException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " not found: " ~ id, file, line);
    }
}
