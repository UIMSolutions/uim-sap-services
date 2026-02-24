module uim.sap.mon.helpers.id;

import uim.sap.mon;

@safe:

string newCheckId(string prefix) {
    return prefix ~ "-" ~ randomUUID().toString();
}
