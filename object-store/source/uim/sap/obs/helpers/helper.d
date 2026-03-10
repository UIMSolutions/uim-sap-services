/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

/// Generate a unique credential ID
string generateCredentialId() {
    return "cred-" ~ randomUUID();
}

/// Generate a unique upload ID for multipart
string generateUploadId() {
    return "upl-" ~ randomUUID();
}

/// Generate a simulated access key ID
string generateAccessKeyId() {
    return "AKIA" ~ randomUUID()[0 .. 16];
}

/// Generate a simulated secret access key
string generateSecretAccessKey() {
    return generateRandomHex(40);
}

/// Generate a simulated session token
string generateSessionToken() {
    return generateRandomHex(64);
}

/// Compute a simulated ETag (content hash)
string computeETag(string key, size_t sizeBytes) {
    import std.conv : to;
    return generateRandomHex(16);
}

/// Generate a cryptographically random hex string
string generateRandomHex(size_t byteLen = 32) {
    import std.digest : toHexString, LetterCase;
    ubyte[] bytes;
    bytes.length = byteLen;
    foreach (ref b; bytes)
        b = cast(ubyte)(hashOf(randomUUID()) & 0xFF);
    return bytes.toHexString!(LetterCase.lower).idup;
}

/// Validate a bucket name (DNS-compatible)
bool isValidBucketName(string name) {
    if (name.length < 3 || name.length > 63) return false;
    // Must start/end with alphanumeric
    if (!isAlphaNum(name[0]) || !isAlphaNum(name[$ - 1])) return false;
    // Only lowercase, digits, hyphens
    foreach (c; name) {
        if (!(c >= 'a' && c <= 'z') && !(c >= '0' && c <= '9') && c != '-')
            return false;
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

/// Format bytes to human-readable string
string formatBytes(size_t bytes) {
    import std.conv : to;
    if (bytes < 1024) return bytes.to!string ~ " B";
    if (bytes < 1024 * 1024) return (bytes / 1024).to!string ~ " KiB";
    if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).to!string ~ " MiB";
    return (bytes / (1024 * 1024 * 1024)).to!string ~ " GiB";
}

/// Provider endpoint URL
string providerEndpoint(OBSProvider provider, string region) {
    final switch (provider) {
        case OBSProvider.awsS3:
            return "https://s3." ~ region ~ ".amazonaws.com";
        case OBSProvider.azureBlob:
            return "https://" ~ region ~ ".blob.core.windows.net";
        case OBSProvider.gcpStorage:
            return "https://storage.googleapis.com";
    }
}

private bool isAlphaNum(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9');
}

private size_t hashOf(string s) {
    size_t h = 0;
    foreach (c; s) h = h * 31 + c;
    return h;
}
