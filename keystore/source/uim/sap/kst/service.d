/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.service;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

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

  this(KSTConfig config) {
    super(config);

    _store = new KSTStore;
  }

  override Json health() {
    Json info = super.health();
    info["keystoreCount"] = cast(long)_store.count();
    return info;
  }

  override Json ready() {
    Json info = super.ready();
    info["keystoreCount"] = cast(long)_store.count();
    return info;
  }

  // ── Keystore CRUD ──

  Json createKeystore(string name, Json request) {
    if (name.length == 0) {
      throw new KSTValidationException("Keystore name is required");
    }
    if (_store.hasKeystore(name)) {
      throw new KSTValidationException("Keystore already exists: " ~ name);
    }
    if (_config.maxKeystores > 0 && _store.count() >= _config.maxKeystores) {
      throw new KSTValidationException("Maximum number of keystores reached");
    }

    auto ks = keystoreFromJson(name, request);
    auto saved = _store.upsertKeystore(ks);

    return Json.emptyObject
      .set("success", true)
      .set("keystore", saved.toJson());
  }

  Json updateKeystore(string name, Json request) {
    if (!_store.hasKeystore(name)) {
      throw new KSTNotFoundException("Keystore", name);
    }

    auto ks = keystoreFromJson(name, request);
    ks.updatedAt = Clock.currTime();
    auto saved = _store.upsertKeystore(ks);

    return Json.emptyObject
      .set("success", true)
      .set("keystore", saved.toJson());
  }

  Json getKeystore(string name) {
    auto ks = _store.getKeystore(name);
    if (ks.name.length == 0) {
      throw new KSTNotFoundException("Keystore", name);
    }

    return Json.emptyObject
      .set("keystore", ks.toJsonDetailed());
  }

  Json listKeystores() {
    auto keystores = _store.listKeystores();
    Json resources = Json.emptyArray;
    foreach (ref ks; keystores)
      resources.appendArrayElement(ks.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)keystores.length);
  }

  Json deleteKeystore(string name) {
    if (!_store.deleteKeystore(name)) {
      throw new KSTNotFoundException("Keystore", name);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Keystore deleted")
      .set("name", name);
  }

  // ── Key Entry operations ──

  Json upsertKeyEntry(string keystoreName, string alias_, Json request, string requestKey) {
    validateKeystore(keystoreName);

    if (!("key_material" in request) || !request["key_material"].isString) {
      throw new KSTValidationException("key_material (string) is required");
    }

    auto entry = keyEntryFromJson(alias_, request);
    auto encryptionKey = resolveEncryptionKey(request, requestKey);
    entry.encryptedMaterial = encryptMaterial(request["key_material"].get!string, encryptionKey);
    entry.updatedAt = Clock.currTime();

    if (!_store.upsertKeyEntry(keystoreName, entry)) {
      throw new KSTNotFoundException("Keystore", keystoreName);
    }

    return Json.emptyObject
      .set("success", true)
      .set("key", entry.toJson());
  }

  Json getKeyEntry(string keystoreName, string alias_, string requestKey) {
    validateKeystore(keystoreName);
    auto entry = _store.getKeyEntry(keystoreName, alias_);
    if (entry.alias_.length == 0) {
      throw new KSTNotFoundException("Key entry", alias_);
    }

    auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
    string plaintext;
    try {
      plaintext = decryptMaterial(entry.encryptedMaterial, key);
    } catch (Exception) {
      {
        throw new KSTCryptoException("Unable to decrypt key material with provided key");
      }
    }

    return entry.toJson()
      .set("key_material", plaintext);
  }

  Json listKeyEntries(string keystoreName) {
    validateKeystore(keystoreName);
    auto entries = _store.listKeyEntries(keystoreName);
    Json resources = Json.emptyArray;
    foreach (ref e; entries)
      resources.appendArrayElement(e.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)entries.length);
  }

  Json deleteKeyEntry(string keystoreName, string alias_) {
    validateKeystore(keystoreName);
    if (!_store.deleteKeyEntry(keystoreName, alias_)) {
      throw new KSTNotFoundException("Key entry", alias_);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Key entry deleted")
      .set("keystore", keystoreName)
      .set("alias", alias_);

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

    if (!_store.upsertCertificate(keystoreName, cert)) {
      throw new KSTNotFoundException("Keystore", keystoreName);
    }

    return Json.emptyObject
      .set("success", true)
      .set("certificate", cert.toJson());
  }

  Json getCertificate(string keystoreName, string alias_, bool includeContent) {
    validateKeystore(keystoreName);
    auto cert = _store.getCertificate(keystoreName, alias_);
    if (cert.alias_.length == 0) {
      throw new KSTNotFoundException("Certificate", alias_);
    }

    return Json.emptyObject
      .set("certificate", includeContent ? cert.toJsonWithContent() : cert.toJson());
  }

  Json listCertificates(string keystoreName) {
    validateKeystore(keystoreName);
    auto certs = _store.listCertificates(keystoreName);
    Json resources = Json.emptyArray;
    foreach (ref c; certs)
      resources.appendArrayElement(c.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)certs.length);
  }

  Json deleteCertificate(string keystoreName, string alias_) {
    validateKeystore(keystoreName);
    if (!_store.deleteCertificate(keystoreName, alias_)) {
      throw new KSTNotFoundException("Certificate", alias_);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Certificate deleted")
      .set("keystore", keystoreName)
      .set("alias", alias_);
  }

  // ── Cryptographic operations ──

  Json sign(string keystoreName, string alias_, Json request, string requestKey) {
    validateKeystore(keystoreName);
    if (!("data" in request) || !request["data"].isString) {
      throw new KSTValidationException("data (string) is required for signing");
    }

    auto entry = _store.getKeyEntry(keystoreName, alias_);
    if (entry.alias_.length == 0) {
      throw new KSTNotFoundException("Key entry", alias_);
    }

    auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
    string keyMaterial;
    try {
      keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
    } catch (Exception) {
      {
        throw new KSTCryptoException("Unable to decrypt key for signing");
      }
    }

    auto data = request["data"].getString;
    auto signature = signData(data, keyMaterial);

    KSTSignResult result = new KSTSignResult;
    result.keystoreName = keystoreName;
    result.keyAlias = alias_;
    result.algorithm = cast(string)entry.algorithm;
    result.signature = signature;
    result.verified = true;
    result.timestamp = Clock.currTime();

    return result.toJson();
  }

  Json verify(string keystoreName, string alias_, Json request, string requestKey) {
    validateKeystore(keystoreName);
    if (!("data" in request) || !request["data"].isString) {
      throw new KSTValidationException("data (string) is required for verification");
    }
    if (!("signature" in request) || !request["signature"].isString) {
      throw new KSTValidationException("signature (string) is required for verification");
    }

    auto entry = _store.getKeyEntry(keystoreName, alias_);
    if (entry.alias_.length == 0) {
      throw new KSTNotFoundException("Key entry", alias_);
    }

    auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
    string keyMaterial;
    try {
      keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
    } catch (Exception) {
      throw new KSTCryptoException("Unable to decrypt key for verification");
    }

    auto data = request["data"].getString;
    auto sig = request["signature"].getString;
    auto valid = verifySignature(data, keyMaterial, sig);

    KSTSignResult result = new KSTSignResult;
    result.keystoreName = keystoreName;
    result.keyAlias = alias_;
    result.algorithm = cast(string)entry.algorithm;
    result.signature = sig;
    result.verified = valid;
    result.timestamp = Clock.currTime();

    return result.toJson();
  }

  Json encrypt(string keystoreName, string alias_, Json request, string requestKey) {
    validateKeystore(keystoreName);
    if (!("plaintext" in request) || !request["plaintext"].isString) {
      throw new KSTValidationException("plaintext (string) is required for encryption");
    }

    auto entry = _store.getKeyEntry(keystoreName, alias_);
    if (entry.alias_.length == 0) {
      throw new KSTNotFoundException("Key entry", alias_);
    }

    auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
    string keyMaterial;
    try {
      keyMaterial = decryptMaterial(entry.encryptedMaterial, key);
    } catch (Exception) {
      throw new KSTCryptoException("Unable to decrypt key for encryption");
    }

    auto plaintext = request["plaintext"].getString;
    auto ciphertext = encryptData(plaintext, keyMaterial);

    return Json.emptyObject
      .set("keystore", keystoreName)
      .set("key_alias", alias_)
      .set("ciphertext", ciphertext)
      .set("algorithm", cast(string)entry.algorithm);
  }

  Json decrypt(string keystoreName, string alias_, Json request, string requestKey) {
    validateKeystore(keystoreName);
    if (!("ciphertext" in request) || !request["ciphertext"].isString) {
      throw new KSTValidationException("ciphertext (string) is required for decryption");
    }

    auto entry = _store.getKeyEntry(keystoreName, alias_);
    if (entry.alias_.length == 0) {
      throw new KSTNotFoundException("Key entry", alias_);
    }

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

    return Json.emptyObject
      .set("keystore", keystoreName)
      .set("key_alias", alias_)
      .set("plaintext", plaintext);
  }

  // ── Client certificate authentication ──

  Json validateClientCert(Json request) {
    if (!_config.enableClientCertAuth) {
      throw new KSTValidationException("Client certificate authentication is not enabled");
    }

    if (!("certificate" in request) || !request["certificate"].isString) {
      throw new KSTValidationException("certificate (string) is required");
    }

    auto certContent = request["certificate"].getString;
    string keystoreName = "trusted-certs";
    if ("keystore" in request && request["keystore"].isString)
      keystoreName = request["keystore"].getString;

    if (!_store.hasKeystore(keystoreName)) {
      throw new KSTNotFoundException("Keystore", keystoreName);
    }

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
    Json payload = Json.emptyObject
      .set("authenticated", found)
      .set("fingerprint", fingerprint);
    
    return found ? payload.set("matched_alias", matchedAlias) : payload;
  }

  // ── Private helpers ──

  private void validateKeystore(string name) {
    if (!_store.hasKeystore(name)) {
      throw new KSTNotFoundException("Keystore", name);
    }
  }

  private string resolveEncryptionKey(Json request, string requestKey) {
    if (requestKey.length > 0) {
      return requestKey;

      if ("encryption_key" in request && request["encryption_key"].isString) {
        auto rk = request["encryption_key"].getString;
        if (rk.length > 0)
          return rk;
      }

      return _config.masterKey;
    }
  }
