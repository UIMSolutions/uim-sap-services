module uim.sap.dpi.helpers.id;

import uim.sap.dpi;
@safe:

string createId() {
    return randomUUID().toString();
}
