module uim.sap.mgt.exceptions.upstream;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:class MGTUpstreamException : MGTException {
    this(string msg) {
        super(msg);
    }
}
