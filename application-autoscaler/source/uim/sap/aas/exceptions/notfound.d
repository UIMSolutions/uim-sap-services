/**
 * Exceptions for AAS service
 */
module uim.sap.aas.exceptions.notfound;

import uim.sap.aas;
@safe:

class AASNotFoundException : AASException {
    this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(entityType ~ " not found: " ~ id, file, line, next);
    }
}

