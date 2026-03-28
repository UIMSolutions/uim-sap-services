module uim.sap.service.classes.tenants.tenant;

import uim.sap.service;

mixin(ShowModule!());

@safe:
class SAPTenant {
  UUID id; // Unique identifier for the tenant
  string name; // Name of the tenant
  string domain; // Custom domain associated with the tenant
  string owner; // Owner of the tenant
  DateTime createdAt; // Creation timestamp
  DateTime updatedAt; // Last updated timestamp
  JsonObject settings; // Tenant-specific settings in JSON format

  // Constructor to initialize a new tenant
  this(UUID id, string name, string domain, string owner, JsonObject settings) {
    this.id = id;
    this.name = name;
    this.domain = domain;
    this.owner = owner;
    this.createdAt = DateTime.nowUTC();
    this.updatedAt = DateTime.nowUTC();
    this.settings = settings;
  }

  // Method to update tenant settings
  void updateSettings(JsonObject newSettings) {
    settings = newSettings;
    updatedAt = DateTime.nowUTC();
  }
}
