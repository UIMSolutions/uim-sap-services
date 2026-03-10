module uim.sap.kst.helpers.helper;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// Generate a hex-encoded fingerprint from content bytes
string generateFingerprint(string content) {
    auto bytes = cast(const(ubyte)[]) content;
    ulong hash = 14695981039346656037UL;
    foreach (b; bytes) {
        hash ^= b;
        hash *= 1099511628211UL;
    }
    // Format as hex string
    char[16] buf;
    foreach (i; 0 .. 16) {
        auto nibble = (hash >> (60 - i * 4)) & 0xF;
        buf[i] = "0123456789abcdef"[cast(size_t) nibble];
    }
    return buf[].idup;
}

/// Generate a random serial number
string generateSerialNumber() {
    return randomUUID().toString().replace("-", "")[0 .. 16];
}
