module btp_extension_service_test;

import vibe.vibe;
import source.services.btp_extension_service;
import std.stdio;
import std.array;
import std.json;
version (unittest) {
} else {
  void main() {
    // Test setup
    auto service = new BtpExtensionService();

    // Example test case: Test domain creation
    void testCreateDomain() {
        auto domainData = JSON.parse(`{"domain": "example.com", "tenantId": "tenant1"}`);
        auto result = service.createDomain(domainData);
        assert(result.success);
        writeln("Domain created successfully: ", result.domain);
    }

    // Example test case: Test domain retrieval
    void testGetDomain() {
        auto result = service.getDomain("example.com");
        assert(result !is null);
        writeln("Domain retrieved: ", result.domain);
    }

    // Run tests
    testCreateDomain();
    testGetDomain();

    writeln("All tests passed.");
}