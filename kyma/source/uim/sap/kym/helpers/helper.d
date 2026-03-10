module uim.sap.kym.helpers.helper;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// Validate a Kubernetes-style resource name (lowercase, alphanumeric, hyphens)
bool isValidResourceName(string name) {
    if (name.length == 0 || name.length > 253)
        return false;
    foreach (c; name) {
        if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-'))
            return false;
    }
    if (name[0] == '-' || name[$ - 1] == '-')
        return false;
    return true;
}

/// Compose a namespaced key
string nsKey(string namespace, string name) {
    return namespace ~ "/" ~ name;
}
