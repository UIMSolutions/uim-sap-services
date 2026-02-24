module certificate_service_test;

import vibe.vibe;
import source.services.certificate_service;
import source.models.certificate;

void main()
{
    // Test cases for CertificateService
    auto service = new CertificateService();

    // Test certificate upload
    void testUploadCertificate()
    {
        Certificate cert = new Certificate("example.com", "certData");
        bool result = service.uploadCertificate(cert);
        assert(result);
    }

    // Test certificate retrieval
    void testGetCertificate()
    {
        auto cert = service.getCertificate("example.com");
        assert(cert !is null);
        assert(cert.domain == "example.com");
    }

    // Test certificate deletion
    void testDeleteCertificate()
    {
        bool result = service.deleteCertificate("example.com");
        assert(result);
    }

    // Run tests
    testUploadCertificate();
    testGetCertificate();
    testDeleteCertificate();
}