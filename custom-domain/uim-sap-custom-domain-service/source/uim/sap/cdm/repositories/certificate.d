module uim.sap.cdm.repositories.certificate;

import models.certificate;
import std.json;
import std.file;
import std.stdio;

class CertificateRepository {
    private string storagePath;

    this(string storagePath) {
        this.storagePath = storagePath;
    }

    void saveCertificate(Certificate cert) {
        auto filePath = storagePath ~ "/" ~ cert.domain ~ ".json";
        auto jsonData = json.serialize(cert);
        writeText(filePath, jsonData);
    }

    Certificate loadCertificate(string domain) {
        auto filePath = storagePath ~ "/" ~ domain ~ ".json";
        if (!exists(filePath)) {
            throw new Exception("Certificate not found for domain: " ~ domain);
        }
        auto jsonData = readText(filePath);
        return json.deserialize!Certificate(jsonData);
    }

    void deleteCertificate(string domain) {
        auto filePath = storagePath ~ "/" ~ domain ~ ".json";
        if (exists(filePath)) {
            remove(filePath);
        } else {
            throw new Exception("Certificate not found for domain: " ~ domain);
        }
    }

    string[] listCertificates() {
        return dirEntries(storagePath)
            .filter!(entry => entry.isFile && entry.name.endsWith(".json"))
            .map!(entry => entry.name.stripSuffix(".json"))
            .array;
    }
}