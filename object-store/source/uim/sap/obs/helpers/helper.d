module uim.sap.obs.helpers.helper;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

/// Generate a unique bucket ID
string generateBucketId() {
    return "bkt-" ~ randomUUID();
}

/// Generate a unique object ID
string generateObjectId() {
    return "obj-" ~ randomUUID();
}

/// Generate a credential ID
string generateCredentialId() {
    return "cred-" ~ randomUUID();
}

/// Generate a policy ID
string generatePolicyId() {
    return "pol-" ~ randomUUID();
}

/// Generate a version ID
string generateVersionId() {
    return "ver-" ~ randomUUID();
}

/// Generate a simulated access key ID
string generateAccessKeyId() {
    return "AKIA" ~ randomHex(16);
}

/// Generate a simulated secret access key
string generateSecretAccessKey() {
    return randomHex(32);
}

/// Compute a simple ETag (simulated MD5-like hash)
string computeETag(string content) {
    size_t h = 5381;
    foreach (c; content)
        h = ((h << 5) + h) + c;
    import std.format : format;
    return format!"%016x"(h);
}

/// Validate a bucket name (S3-style naming rules)
bool isValidBucketName(string name) {
    if (name.length < 3 || name.length > 63) return false;
    // Must start/end with alphanumeric
    if (!isAlphaNum(name[0]) || !isAlphaNum(name[$ - 1])) return false;
    foreach (c; name) {
        if (!isAlphaNum(c) && c != '-' && c != '.') return false;
    }
    return true;
}

/// Validate an object key
bool isValidObjectKey(string key) {
    if (key.length == 0 || key.length > 1024) return false;
    // Must not start with /
    if (key[0] == '/') return false;
    return true;
}

/// Get the endpoint URL for a provider and region
string providerEndpoint(OBSProvider provider, string region) {
    final switch (provider) {
        case OBSProvider.aws:
            return "https://s3." ~ region ~ ".amazonaws.com";
        case OBSProvider.azure:
            return "https://" ~ region ~ ".blob.core.windows.net";
        case OBSProvider.gcp:
            return "https://storage.googleapis.com";
    }
}

/// Format size in human-readable form
string formatSize(size_t bytes) {
    import std.format : format;
    if (bytes < 1024) return format!"%d B"(bytes);
    if (bytes < 1_048_576) return format!"%.1f KB"(cast(double) bytes / 1024);
    if (bytes < 1_073_741_824) return format!"%.1f MB"(cast(double) bytes / 1_048_576);
    return format!"%.2f GB"(cast(double) bytes / 1_073_741_824);
}

private bool isAlphaNum(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9');
}

private string randomHex(size_t len) {
    import std.digest : toHexString, LetterCase;
    ubyte[] bytes;
    bytes.length = len;
    foreach (i, ref b; bytes)
        b = cast(ubyte)((hashOf(randomUUID(), i) >> 3) & 0xFF);
    return bytes.toHexString!(LetterCase.lower).idup;
}

private size_t hashOf(string s, size_t seed = 0) {
    size_t h = seed;
    foreach (c; s) h = h * 31 + c;
    return h;
}
