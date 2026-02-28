module uim.sap.cis.helpers.helper;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

string createId() {
    return randomUUID().toString();
}

string normalizeMode(string mode) {
    auto value = toLower(mode);
    return (value == "delta") ? "delta" : "full";
}
