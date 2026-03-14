/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.crypto;

import std.uuid : randomUUID;

import uim.sap.kst.models;
import uim.sap.kst.exceptions;

/// Encrypt plaintext material using a key stream cipher
KSTEncryptedPayload encryptMaterial(string plaintext, string key) {
    KSTEncryptedPayload payload;
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

/// Decrypt cipher material using a key stream cipher
string decryptMaterial(KSTEncryptedPayload payload, string key) {
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
        throw new KSTCryptoException("Invalid encryption key or corrupted key material");
    }

    return fromBytes(plainBytes);
}

/// Sign data using a key (HMAC-like keyed hash)
string signData(string data, string key) {
    auto dataBytes = toBytes(data);
    auto keyBytes = toBytes(key);
    if (keyBytes.length == 0) {
        throw new KSTCryptoException("Signing key cannot be empty");
    }

    // HMAC-like construction: H(key XOR opad || H(key XOR ipad || message))
    enum BLOCK_SIZE = 64;
    ubyte[BLOCK_SIZE] paddedKey;
    paddedKey[] = 0;
    auto kLen = keyBytes.length < BLOCK_SIZE ? keyBytes.length : BLOCK_SIZE;
    paddedKey[0 .. kLen] = keyBytes[0 .. kLen];

    ubyte[BLOCK_SIZE] ipadKey;
    ubyte[BLOCK_SIZE] opadKey;
    foreach (i; 0 .. BLOCK_SIZE) {
        ipadKey[i] = paddedKey[i] ^ 0x36;
        opadKey[i] = paddedKey[i] ^ 0x5c;
    }

    // Inner hash
    ulong innerHash = fnvInit();
    foreach (b; ipadKey)
        innerHash = fnvStep(innerHash, b);
    foreach (b; dataBytes)
        innerHash = fnvStep(innerHash, b);

    // Outer hash
    ulong outerHash = fnvInit();
    foreach (b; opadKey)
        outerHash = fnvStep(outerHash, b);
    // Feed inner hash bytes into outer
    foreach (i; 0 .. 8) {
        outerHash = fnvStep(outerHash, cast(ubyte)((innerHash >> (i * 8)) & 0xFF));
    }

    // Convert to hex
    char[16] buf;
    foreach (i; 0 .. 16) {
        auto nibble = (outerHash >> (60 - i * 4)) & 0xF;
        buf[i] = "0123456789abcdef"[cast(size_t) nibble];
    }
    return buf[].idup;
}

/// Verify a signature against data and key
bool verifySignature(string data, string key, string signature) {
    auto computed = signData(data, key);
    if (computed.length != signature.length) return false;

    // Constant-time comparison
    ubyte diff = 0;
    foreach (i; 0 .. computed.length) {
        diff |= cast(ubyte)(computed[i] ^ signature[i]);
    }
    return diff == 0;
}

/// Encrypt plaintext data using a key
string encryptData(string plaintext, string key) {
    auto encrypted = encryptMaterial(plaintext, key);
    // Encode as hex: nonce_hex:cipher_hex:checksum
    return bytesToHex(encrypted.nonceBytes) ~ ":" ~
           bytesToHex(encrypted.cipherBytes) ~ ":" ~
           to!string(encrypted.checksum);
}

/// Decrypt ciphertext data using a key
string decryptData(string ciphertext, string key) {
    import std.array : split;
    auto parts = ciphertext.split(":");
    if (parts.length != 3) {
        throw new KSTCryptoException("Invalid encrypted data format");
    }
    KSTEncryptedPayload payload;
    payload.nonceBytes = hexToBytes(parts[0]);
    payload.cipherBytes = hexToBytes(parts[1]);
    payload.checksum = to!ulong(parts[2]);
    return decryptMaterial(payload, key);
}

private ubyte[] toBytes(string value) {
    return cast(ubyte[]) value.dup;
}

private string fromBytes(ubyte[] value) {
    return cast(string) cast(char[]) value;
}

private ulong checksum(const(ubyte)[] value) {
    ulong result = fnvInit();
    foreach (b; value) {
        result = fnvStep(result, b);
    }
    return result;
}

private ulong fnvInit() {
    return 14695981039346656037UL;
}

private ulong fnvStep(ulong hash, ubyte b) {
    hash ^= b;
    hash *= 1099511628211UL;
    return hash;
}

private string bytesToHex(const(ubyte)[] bytes) {
    char[] result;
    result.length = bytes.length * 2;
    foreach (i, b; bytes) {
        result[i * 2] = "0123456789abcdef"[b >> 4];
        result[i * 2 + 1] = "0123456789abcdef"[b & 0xF];
    }
    return result.idup;
}

private ubyte[] hexToBytes(string hex) {
    if (hex.length % 2 != 0) return [];
    ubyte[] result;
    result.length = hex.length / 2;
    foreach (i; 0 .. result.length) {
        result[i] = cast(ubyte)((hexDigit(hex[i * 2]) << 4) | hexDigit(hex[i * 2 + 1]));
    }
    return result;
}

private ubyte hexDigit(char c) {
    if (c >= '0' && c <= '9') return cast(ubyte)(c - '0');
    if (c >= 'a' && c <= 'f') return cast(ubyte)(c - 'a' + 10);
    if (c >= 'A' && c <= 'F') return cast(ubyte)(c - 'A' + 10);
    return 0;
}
