module uim.sap.kst.service;

import std.datetime : Clock;

import vibe.data.json : Json;

import uim.sap.kst.config;
import uim.sap.kst.crypto;
import uim.sap.kst.enumerations;
import uim.sap.kst.exceptions;
import uim.sap.kst.helpers;
import uim.sap.kst.models;
import uim.sap.kst.store;

/**
 * Main service class for the Keystore Service.
 *
 * Responsibilities:
 * - Manage keystores (CRUD)
 * - Manage key entries within keystores
 * - Manage certificates within keystores
 * - Sign and verify digital signatures
 * - Encrypt and decrypt messages
 * - Provide health and readiness checks
 */
class KSTService : SAPService {
    mixin(SAPServiceTemplate!KSTService);

    private KSTStore _store;
    private KSTConfig _config;

    this(KSTConfig config) {
        super(config);
        _config = config;
        _store = new KSTStore;
    }

    @property KSTConfig config() { return _config; }

    override Json health() {
        Json info = super.health();
        info["keystoreCount"] = cast(long) _store.count();
        return info;
    }

    override Json ready() {
        Json info = super.ready();
        info["keystoreCount"] = cast(long) _store.count();
        return info;
    }

    // ── Keystore CRUD ──

    Json createKeystore(string name, Json request) {
        if (name.length == 0)
            throw new KSTValidationException("Keystore name is required");
        if (_store.hasKeystore(name))
            throw new KSTValidationException("Keystore already exists: " ~ name);
        if (_config.maxKeystores > 0 && _store.count() >= _config.maxKeystores)
            throw new KSTValidationException("Maximum number of keystores reached");

        auto ks = keystoreFromJson(name, request);
        auto saved = _store.upsertKeystore(ks);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["keystore"] = saved.toJson();
        return payload;
    }

    Json updateKeystore(string name, Json request) {
        if (!_store.hasKeystore(name))
            throw new KSTNotFoundException("Keystore", name);

        auto ks = keystoreFromJson(name, request);
        ks.updatedAt = Clock.currTime();
        auto saved = _store.upsertKeystore(ks);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["keystore"] = saved.toJson();
        return payload;
    }

    Json getKeystore(string name) {
        auto ks = _store.getKeystore(name);
        if (ks.name.length == 0)
            throw new KSTNotFoundException("Keystore", name);

        Json payload = Json.emptyObject;
        payload["keystore"] = ks.toJsonDetailed();
        return payload;
    }

    Json listKeystores() {
        auto keystores = _store.listKeystores();
        Json resources = Json.emptyArray;
        foreach (ref ks; keystores)
            resources.appendArrayElement(ks.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) keystores.length;
        return payload;
    }

    Json deleteKeystore(string name) {
        if (!_store.deleteKeystore(name))
            throw new KSTNotFoundException("Keystore", name);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Keystore deleted";
        payload["name"] = name;
        return payload;
    }

    // ── Key Entry operations ──

    Json upsertKeyEntry(string keystoreName, string alias_, Json request, string requestKey) {
        validateKeystore(keystoreName);

        if (!("key_material" in request) || !request["key_material"].isString)
            throw new KSTValidationException("key_material (string) is required");

        auto entry = keyEntryFromJson(alias_, request);
        auto encryptionKey = resolveEncryptionKey(request, requestKey);
        entry.encryptedMaterial = encryptMaterial(request["key_material"].get!string, encryptionKey);
        entry.updatedAt = Clock.currTime();

        if (!_store.upsertKeyEntry(keystoreName, entry))
            throw new KSTNotFoundException("Keystore", keystoreName);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["key"] = entry.toJson();
        return payload;
    }

    Json getKeyEntry(string keystoreName, string alias_, string requestKey) {
        validateKeystore(keystoreName);
        auto entry = _store.getKeyEntry(keystoreName, alias_);
        if (entry.alias_.length == 0)
            throw new KSTNotFoundException("Key entry", alias_);

        auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
        string plaintext;
        try {
            plaintext = decryptMaterial(entry.encryptedMaterial, key);
        } catch (Exception) {
            throw new KSTCryptoException("Unable to decrypt key material with provided key");
        }

        Json payload = entry.toJson();
        payload["key_material"] = plaintext;
        return payload;
    }

    Json listKeyEntries(string keystoreName) {
        validateKeystore(keystoreName);
        auto entries = _store.listKeyEntries(keystoreName);
        Json resources = Json.emptyArray;
        foreach (ref e; entries)
            resources.appendArrayElement(e.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) entries.length;
        return payload;
    }

    Json deleteKeyEntry(string keystoreName, string alias_) {
        validateKeystore(keystoreName);
        if (!_store.deleteKeyEntry(keystoreName, alias_))
            throw new KSTNotFoundException("Key entry", alias_);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Key entry deleted";
        payload["keystore"] = keystoreName;
        payload["alias"] = alias_;
        return payload;
    }

    // ── Certificate operations ──

    Json upsertCertificate(string keystoreName, string alias_, Json request) {
        validateKeystore(keystoreName);

        auto cert = certificateFromJson(request);
        cert.alias_ = alias_;
        if (cert.fingerprint.length == 0 && cert.content.length > 0)
            cert.fingerprint = generateFingerprint(cert.content);
        if (cert.serialNumber.length == 0)
            cert.serialNumber = generateSerialNumber();

        if (!_store.upsertCertificate(keystoreName, cert))
            throw new KSTNotFoundException("Keystore", keystoreName);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["certificate"] = cert.toJson();
        return payload;
    }

    Json getCertificate(string keystoreName, string alias_, bool includeContent) {
        validateKeystore(keystoreName);
        auto cert = _store.getCertificate(keystoreName, alias_);
        if (cert.alias_.length == 0)
            throw new KSTNotFoundException("Certificate", alias_);

        Json payload = Json.emptyObject;
        payload["certificate"] = includeContent ? cert.toJsonWithContent() : cert.toJson();
        return payload;
    }

    Json listCertificates(string keystoreName) {
        validateKeystore(keystoreName);
        auto certs = _store.listCertificates(keystoreName);
        Json resources = Json.emptyArray;
        foreach (ref c; certs)
            resources.appendArrayElement(c.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) certs.length;
        return payload;
    }

    Json deleteCertificate(string keystoreName, string alias_) {
        validateKeystore(keystoreName);
        if (!_store.deleteCertificate(keystoreName, alias_))
            throw new KSTNotFoundException("Certificate", alias_);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Certificate deleted";
        payload["keystore"] = keystoreName;
        payload["alias"] = alias_;
        return payload;
    }

    // ── Cryptographic operations ──

    Json sign(string keystoreName, string alias_, Json request, string requestKey) {
        validateKeystore(keystoreName);
        if (!("data" in request) || !request["data"].isString)
            throw new KSTValidationException("data (string) is required for signing");

        auto entry = _store.getKeyEntry(keystoreName, alias_);
        if (entry.alias_.length == 0)
            throw new KSTNotFoundException("Key entry", alias_);

        auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
        string keyMaterial;
        try {
            keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
        } catch (Exception) {
            throw new KSTCryptoException("Unable to decrypt key for signing");
        }

        auto data = request["data"].get!string;
        auto signature = signData(data, keyMaterial);

        KSTSignResult result;
        result.keystoreName = keystoreName;
        result.keyAlias = alias_;
        result.algorithm = cast(string) entry.algorithm;
        result.signature = signature;
        result.verified = true;
        result.timestamp = Clock.currTime();

        return result.toJson();
    }

    Json verify(string keystoreName, string alias_, Json request, string requestKey) {
        validateKeystore(keystoreName);
        if (!("data" in request) || !request["data"].isString)
            throw new KSTValidationException("data (string) is required for verification");
        if (!("signature" in request) || !request["signature"].isString)
            throw new KSTValidationException("signature (string) is required for verification");

        auto entry = _store.getKeyEntry(keystoreName, alias_);
        if (entry.alias_.length == 0)
            throw new KSTNotFoundException("Key entry", alias_);

        auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
        string keyMaterial;
        try {
            keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
        } catch (Exception) {
            throw new KSTCryptoException("Unable to decrypt key for verification");
        }

        auto data = request["data"].get!string;
        auto sig = request["signature"].get!string;
        auto valid = verifySignature(data, keyMaterial, sig);

        KSTSignResult result;
        result.keystoreName = keystoreName;
        result.keyAlias = alias_;
        result.algorithm = cast(string) entry.algorithm;
        result.signature = sig;
        result.verified = valid;
        result.timestamp = Clock.currTime();

        return result.toJson();
    }

    Json encrypt(string keystoreName, string alias_, Json request, string requestKey) {
        validateKeystore(keystoreName);
        if (!("plaintext" in request) || !request["plaintext"].isString)
            throw new KSTValidationException("plaintext (string) is required for encryption");

        auto entry = _store.getKeyEntry(keystoreName, alias_);
        if (entry.alias_.length == 0)
            throw new KSTNotFoundException("Key entry", alias_);

        auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
        string keyMaterial;
        try {
            keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
        } catch (Exception) {
            throw new KSTCryptoException("Unable to decrypt key for encryption");
        }

        auto plaintext = request["plaintext"].get!string;
        auto ciphertext = encryptData(plaintext, keyMaterial);

        Json payload = Json.emptyObject;
        payload["keystore"] = keystoreName;
        payload["key_alias"] = alias_;
        payload["ciphertext"] = ciphertext;
        payload["algorithm"] = cast(string) entry.algorithm;
        return payload;
    }

    Json decrypt(string keystoreName, string alias_, Json request, string requestKey) {
        validateKeystore(keystoreName);
        if (!("ciphertext" in request) || !request["ciphertext"].isString)
            throw new KSTValidationException("ciphertext (string) is required for decryption");

        auto entry = _store.getKeyEntry(keystoreName, alias_);
        if (entry.alias_.length == 0)
            throw new KSTNotFoundException("Key entry", alias_);

        auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
        string keyMaterial;
        try {
            keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
        } catch (Exception) {
            throw new KSTCryptoException("Unable to decrypt key for decryption");
        }

        string plaintext;
        try {
            plaintext = decryptData(request["ciphertext"].get!string, keyMaterial);
        } catch (Exception) {
            throw new KSTCryptoException("Unable to decrypt data");
        }

        Json payload = Json.emptyObject;
        payload["keystore"] = keystoreName;
        payload["key_alias"] = alias_;
        payload["plaintext"] = plaintext;
        return payload;
    }

    // ── Client certificate authentication ──

    Json validateClientCert(Json request) {
        if (!_config.enableClientCertAuth)
            throw new KSTValidationException("Client certificate authentication is not enabled");

        if (!("certificate" in request) || !request["certificate"].isString)
            throw new KSTValidationException("certificate (string) is required");

        auto certContent = request["certificate"].get!string;
        string keystoreName = "trusted-certs";
        if ("keystore" in request && request["keystore"].isString)
            keystoreName = request["keystore"].get!string;

        if (!_store.hasKeystore(keystoreName))
            throw new KSTNotFoundException("Keystore", keystoreName);

        auto fingerprint = generateFingerprint(certContent);
        auto trustedCerts = _store.listCertificates(keystoreName);

        bool found = false;
        string matchedAlias;
        foreach (ref cert; trustedCerts) {
            if (cert.fingerprint == fingerprint) {
                found = true;
                matchedAlias = cert.alias_;
                break;
            }
        }

        Json payload = Json.emptyObject;
        payload["authenticated"] = found;
        payload["fingerprint"] = fingerprint;
        if (found) {
            payload["matched_alias"] = matchedAlias;
        }
        return payload;
    }

    // ── Private helpers ──

    private void validateKeystore(string name) {
        if (!_store.hasKeystore(name))
            throw new KSTNotFoundException("Keystore", name);
    }

    private string resolveEncryptionKey(Json request, string requestKey) {
        if (requestKey.length > 0)
            return requestKey;
        if ("encryption_key" in request && request["encryption_key"].isString) {
            auto rk = request["encryption_key"].get!string;
            if (rk.length > 0)
                return rk;
        }
        return _config.masterKey;
    }
}
