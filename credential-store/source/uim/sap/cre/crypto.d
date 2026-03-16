module uim.sap.cre.crypto;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

CREEncryptedPayload encryptString(string plaintext, string key) {
    CREEncryptedPayload payload;
    auto plainBytes = toBytes(plaintext);
    auto keyBytes = toBytes(key);
    auto nonceBytes = toBytes(randomUUID().toString());

    if (keyBytes.length == 0) {
        keyBytes = toBytes("fallback-key");
    }

    payload.nonceBytes = nonceBytes;
    payload.cipherBytes.length = plainBytes.length;

    foreach (idx; 0 .. plainBytes.length) {
        auto keyIndex = (idx + nonceBytes[idx % nonceBytes.length]) % keyBytes.length;
        ubyte streamByte = keyBytes[keyIndex] ^ nonceBytes[idx % nonceBytes.length];
        payload.cipherBytes[idx] = plainBytes[idx] ^ streamByte;
    }

    payload.checksum = checksum(plainBytes);
    return payload;
}

string decryptString(CREEncryptedPayload payload, string key) {
    auto keyBytes = toBytes(key);
    if (keyBytes.length == 0) {
        keyBytes = toBytes("fallback-key");
    }
    auto plainBytes = payload.cipherBytes.dup;

    foreach (idx; 0 .. plainBytes.length) {
        auto keyIndex = (idx + payload.nonceBytes[idx % payload.nonceBytes.length]) % keyBytes.length;
        ubyte streamByte = keyBytes[keyIndex] ^ payload.nonceBytes[idx % payload.nonceBytes.length];
        plainBytes[idx] = payload.cipherBytes[idx] ^ streamByte;
    }

    if (checksum(plainBytes) != payload.checksum) {
        throw new Exception("Invalid encryption key or corrupted payload");
    }

    return fromBytes(plainBytes);
}

private ubyte[] toBytes(string value) {
    return cast(ubyte[])value.dup;
}

private string fromBytes(ubyte[] value) {
    return cast(string)cast(char[])value;
}

private ulong checksum(const(ubyte)[] value) {
    ulong result = 1469598103934665603UL;
    foreach (b; value) {
        result ^= b;
        result *= 1099511628211UL;
    }
    return result;
}
