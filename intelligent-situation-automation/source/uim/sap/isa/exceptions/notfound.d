module uim.sap.isa.exceptions.notfound;

import uim.sap.isa.exceptions.exception;

class ISANotFoundException : ISAException {
    this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(entityType ~ " not found: " ~ id, file, line, next);
    }
}
