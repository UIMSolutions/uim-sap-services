module controllers.identity_controller;

import vibe.vibe;
import services.certificate_service;
import models.certificate;

class IdentityController {
    private CertificateService certificateService;

    this(CertificateService certService) {
        this.certificateService = certService;
    }

    void uploadCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        auto certData = req.bodyReader.readText();
        auto cert = parseCertificate(certData);

        if (certificateService.uploadCertificate(cert)) {
            res.status = HTTPStatus.created;
            res.writeBody("Certificate uploaded successfully.");
        } else {
            res.status = HTTPStatus.badRequest;
            res.writeBody("Failed to upload certificate.");
        }
    }

    private Certificate parseCertificate(string certData) {
        // Logic to parse the certificate data from the string
        return new Certificate(certData);
    }
}