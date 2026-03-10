module uim.sap.pdm.helpers.helper;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Generate a unique subject ID
string generateSubjectId() {
    return "sub-" ~ randomUUID();
}

/// Generate a unique request ID
string generateRequestId() {
    return "req-" ~ randomUUID();
}

/// Generate a unique record ID
string generateRecordId() {
    return "rec-" ~ randomUUID();
}

/// Generate a unique notification ID
string generateNotificationId() {
    return "ntf-" ~ randomUUID();
}

/// Generate a unique tenant ID
string generateTenantId() {
    return "tnt-" ~ randomUUID();
}

/// Generate a unique usage ID
string generateUsageId() {
    return "usg-" ~ randomUUID();
}

/// Simple email validation
bool isValidEmail(string email) {
    if (email.length < 5) return false;
    import std.algorithm : canFind;
    auto atPos = email.canFind('@');
    return atPos;
}

/// Compose a tenant-scoped key
string tenantKey(string tenantId, string resourceId) {
    return tenantId ~ "/" ~ resourceId;
}

/// Check if a search term matches a data subject (case-insensitive partial match)
bool matchesSubject(PDMDataSubject s, string term) {
    import std.uni : toLower;
    string t = term.toLower;
    if (s.firstName.toLower.canFind(t)) return true;
    if (s.lastName.toLower.canFind(t)) return true;
    if (s.displayName.toLower.canFind(t)) return true;
    if (s.email.toLower.canFind(t)) return true;
    if (s.companyName.toLower.canFind(t)) return true;
    if (s.externalId.toLower.canFind(t)) return true;
    return false;
}

private bool canFind(string haystack, string needle) {
    if (needle.length == 0 || haystack.length == 0) return false;
    if (needle.length > haystack.length) return false;
    foreach (i; 0 .. haystack.length - needle.length + 1) {
        if (haystack[i .. i + needle.length] == needle) return true;
    }
    return false;
}
