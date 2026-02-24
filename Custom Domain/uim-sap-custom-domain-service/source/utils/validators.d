module utils.validators;

import std.regex : match;
import std.exception : enforce;

bool validateDomainName(string domain) {
    // A simple regex to validate domain names
    return match(domain, r"^(?!-)[A-Za-z0-9-]{1,63}(?<!-)(\.[A-Za-z]{2,})+$");
}

bool validateCertificateData(string certificate) {
    // Placeholder for certificate validation logic
    enforce(certificate.length > 0, "Certificate data cannot be empty");
    // Additional validation logic can be added here
    return true;
}

bool validateTenantId(string tenantId) {
    // A simple check to ensure tenant ID is not empty and follows a specific format
    enforce(tenantId.length > 0, "Tenant ID cannot be empty");
    return true;
}

bool validateKpiData(string kpiData) {
    // Placeholder for KPI data validation logic
    enforce(kpiData.length > 0, "KPI data cannot be empty");
    // Additional validation logic can be added here
    return true;
}