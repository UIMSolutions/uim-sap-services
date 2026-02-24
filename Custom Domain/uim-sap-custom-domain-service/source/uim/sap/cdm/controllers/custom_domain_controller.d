module controllers.custom_domain_controller;

import vibe.vibe;
import services.custom_domain_service;
import models.custom_domain;

class CustomDomainController {
    private CustomDomainService customDomainService;

    this() {
        customDomainService = new CustomDomainService();
    }

    // Endpoint to create a new custom domain
    void createCustomDomain(HttpRequest req, HttpResponse res) {
        auto domainData = req.jsonBody;
        auto customDomain = customDomainService.createDomain(domainData);
        res.status = 201;
        res.json(customDomain);
    }

    // Endpoint to retrieve a custom domain by ID
    void getCustomDomain(HttpRequest req, HttpResponse res) {
        auto domainId = req.params["id"];
        auto customDomain = customDomainService.getDomain(domainId);
        if (customDomain is null) {
            res.status = 404;
            res.writeBody("Custom domain not found");
            return;
        }
        res.json(customDomain);
    }

    // Endpoint to update a custom domain
    void updateCustomDomain(HttpRequest req, HttpResponse res) {
        auto domainId = req.params["id"];
        auto domainData = req.jsonBody;
        auto updatedDomain = customDomainService.updateDomain(domainId, domainData);
        if (updatedDomain is null) {
            res.status = 404;
            res.writeBody("Custom domain not found");
            return;
        }
        res.json(updatedDomain);
    }

    // Endpoint to delete a custom domain
    void deleteCustomDomain(HttpRequest req, HttpResponse res) {
        auto domainId = req.params["id"];
        if (!customDomainService.deleteDomain(domainId)) {
            res.status = 404;
            res.writeBody("Custom domain not found");
            return;
        }
        res.status = 204; // No Content
    }

    // Endpoint to list all custom domains
    void listCustomDomains(HttpRequest req, HttpResponse res) {
        auto domains = customDomainService.listDomains();
        res.json(domains);
    }
}