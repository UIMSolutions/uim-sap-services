module uim.sap.kym.exceptions.quota;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMQuotaExceededException : KYMException {
    this(string resource, size_t limit) {
        import std.conv : to;
        super("Quota exceeded for " ~ resource ~ ": maximum " ~ to!string(limit));
    }
}
