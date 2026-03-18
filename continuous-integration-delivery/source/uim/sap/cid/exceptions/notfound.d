module uim.sap.cid.exceptions.notfound;

import uim.sap.cid;

mixin(ShowModule!());

@safe:
class CIDNotFoundException : CIDException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
