module uim.sap.kym.exceptions.conflict;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMConflictException : KYMException {
    this(string kind, string id) {
        super(kind ~ " already exists: " ~ id);
    }
}
