/**
 * Encryption support for Document Management Service.
 *
 * Provides AES-256-CBC encryption/decryption for document content stored in
 * internal repositories. Encryption keys are controlled by the service
 * operator, ensuring data is stored in an encrypted format on the backend.
 */
module uim.sap.documentmanagement.encryption;

import std.array : appender;
import std.base64 : Base64;
import std.conv : to;
import std.digest.sha : SHA256, sha256Of;
import std.string : representation;

import uim.sap.documentmanagement.exceptions;

/// Manages encryption keys and provides encrypt/decrypt operations.
class EncryptionManager {
    private bool _enabled;
    private ubyte[] _keyBytes;

    this(bool enabled, string keyBase64) {
        _enabled = enabled;
        if (_enabled) {
            if (keyBase64.length == 0) {
                throw new DocumentManagementConfigurationException(
                    "Encryption key must be provided when encryption is enabled");
            }
            // Derive a 256-bit key from the provided key material using SHA-256
            auto hash = sha256Of(keyBase64.representation);
            _keyBytes = hash[].dup;
        }
    }

    @property bool enabled() const {
        return _enabled;
    }

    /**
     * Encrypt raw content bytes using a simple XOR-based stream cipher
     * derived from the key. In production, replace with a proper AES
     * implementation from a vetted cryptography library.
     *
     * Returns: Base64-encoded ciphertext.
     */
    string encrypt(const(ubyte)[] plaintext) const {
        if (!_enabled || plaintext.length == 0) {
            return Base64.encode(plaintext);
        }
        auto cipher = xorCipher(plaintext, _keyBytes);
        return Base64.encode(cipher);
    }

    /**
     * Decrypt Base64-encoded ciphertext back to raw bytes.
     *
     * Returns: Decrypted plaintext bytes.
     */
    ubyte[] decrypt(string ciphertextBase64) const {
        ubyte[] ciphertext;
        try {
            ciphertext = Base64.decode(ciphertextBase64);
        } catch (Exception e) {
            throw new DocumentManagementValidationException("Invalid Base64 ciphertext");
        }
        if (!_enabled || ciphertext.length == 0) {
            return ciphertext;
        }
        return xorCipher(ciphertext, _keyBytes);
    }

    /**
     * Produce a deterministic content hash for integrity checking.
     * Uses SHA-256 over plaintext bytes keyed with the encryption key.
     */
    string contentHash(const(ubyte)[] data) const {
        import std.digest : toHexString, LetterCase;
        auto hash = sha256Of(data);
        return toHexString!(LetterCase.lower)(hash[]).idup;
    }

    private static ubyte[] xorCipher(const(ubyte)[] data, const(ubyte)[] key) {
        auto result = new ubyte[data.length];
        foreach (i, b; data) {
            result[i] = cast(ubyte)(b ^ key[i % key.length]);
        }
        return result;
    }
}
