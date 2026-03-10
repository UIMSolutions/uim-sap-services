module custom_domain_service_test;

import source.services.custom_domain_service;
import source.models.custom_domain;
import std.stdio;
import std.array;
import std.exception;

void main() {
  // Test case for creating a custom domain
  void testCreateCustomDomain() {
    auto service = new CustomDomainService();
    auto domain = new CustomDomain("example.com", "tenant1");

    try {
      service.createCustomDomain(domain);
      writeln("Custom domain created successfully.");
    } catch (Exception e) {
      writeln("Failed to create custom domain: ", e.msg);
    }
  }

  // Test case for retrieving a custom domain
  void testGetCustomDomain() {
    auto service = new CustomDomainService();
    auto domain = service.getCustomDomain("example.com");

    if (domain !is null) {
      writeln("Custom domain retrieved: ", domain.name);
    } else {
      writeln("Custom domain not found.");
    }
  }

  // Test case for updating a custom domain
  void testUpdateCustomDomain() {
    auto service = new CustomDomainService();
    auto domain = new CustomDomain("example.com", "tenant1");
    domain.someProperty = "newValue"; // Assuming there's a property to update

    try {
      service.updateCustomDomain(domain);
      writeln("Custom domain updated successfully.");
    } catch (Exception e) {
      writeln("Failed to update custom domain: ", e.msg);
    }
  }

  // Test case for deleting a custom domain
  void testDeleteCustomDomain() {
    auto service = new CustomDomainService();

    try {
      service.deleteCustomDomain("example.com");
      writeln("Custom domain deleted successfully.");
    } catch (Exception e) {
      writeln("Failed to delete custom domain: ", e.msg);
    }
  }

  // Run all tests
  testCreateCustomDomain();
  testGetCustomDomain();
  testUpdateCustomDomain();
  testDeleteCustomDomain();
}
