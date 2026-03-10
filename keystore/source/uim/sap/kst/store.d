module uim.sap.kst.store;

import core.sync.mutex : Mutex;

import uim.sap.kst.models;

/**
 * In-memory keystore repository.
 *
 * Stores keystores, their key entries, and certificates.
 * Thread-safe via mutex synchronization.
 */
class KSTStore : SAPStore {
    private KSTKeystore[string] _keystores;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // ── Keystore CRUD ──

    KSTKeystore upsertKeystore(KSTKeystore ks) {
        synchronized (_lock) {
            if (auto existing = ks.name in _keystores) {
                ks.createdAt = existing.createdAt;
                // Preserve existing keys and certs when updating metadata
                if (ks.keys.length == 0)
                    ks.keys = existing.keys;
                if (ks.certificates.length == 0)
                    ks.certificates = existing.certificates;
            }
            _keystores[ks.name] = ks;
            return ks;
        }
    }

    bool deleteKeystore(string name) {
        synchronized (_lock) {
            if ((name in _keystores) is null)
                return false;
            _keystores.remove(name);
            return true;
        }
    }

    bool hasKeystore(string name) {
        synchronized (_lock) {
            return (name in _keystores) !is null;
        }
    }

    KSTKeystore getKeystore(string name) {
        synchronized (_lock) {
            if (auto ks = name in _keystores)
                return *ks;
        }
        return KSTKeystore.init;
    }

    KSTKeystore[] listKeystores() {
        KSTKeystore[] values;
        synchronized (_lock) {
            foreach (item; _keystores.byValue)
                values ~= item;
        }
        return values;
    }

    size_t count() {
        synchronized (_lock) {
            return _keystores.length;
        }
    }

    // ── Key Entry operations ──

    bool upsertKeyEntry(string keystoreName, KSTKeyEntry entry) {
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                if (auto existing = entry.alias_ in ks.keys)
                    entry.createdAt = existing.createdAt;
                ks.keys[entry.alias_] = entry;
                ks.updatedAt = entry.updatedAt;
                return true;
            }
            return false;
        }
    }

    bool deleteKeyEntry(string keystoreName, string alias_) {
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                if ((alias_ in ks.keys) is null)
                    return false;
                ks.keys.remove(alias_);
                return true;
            }
            return false;
        }
    }

    KSTKeyEntry getKeyEntry(string keystoreName, string alias_) {
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                if (auto entry = alias_ in ks.keys)
                    return *entry;
            }
        }
        return KSTKeyEntry.init;
    }

    KSTKeyEntry[] listKeyEntries(string keystoreName) {
        KSTKeyEntry[] values;
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                foreach (item; ks.keys.byValue)
                    values ~= item;
            }
        }
        return values;
    }

    // ── Certificate operations ──

    bool upsertCertificate(string keystoreName, KSTCertificate cert) {
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                ks.certificates[cert.alias_] = cert;
                ks.updatedAt = cert.createdAt;
                return true;
            }
            return false;
        }
    }

    bool deleteCertificate(string keystoreName, string alias_) {
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                if ((alias_ in ks.certificates) is null)
                    return false;
                ks.certificates.remove(alias_);
                return true;
            }
            return false;
        }
    }

    KSTCertificate getCertificate(string keystoreName, string alias_) {
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                if (auto cert = alias_ in ks.certificates)
                    return *cert;
            }
        }
        return KSTCertificate.init;
    }

    KSTCertificate[] listCertificates(string keystoreName) {
        KSTCertificate[] values;
        synchronized (_lock) {
            if (auto ks = keystoreName in _keystores) {
                foreach (item; ks.certificates.byValue)
                    values ~= item;
            }
        }
        return values;
    }
}
