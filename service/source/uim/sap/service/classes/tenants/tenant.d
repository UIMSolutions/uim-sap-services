module uim.sap.service.classes.tenants.tenant;

import uim.sap.service;

mixin(ShowModule!());

@safe:
class SAPTenant : ISAPTenant {
  // Constructor to initialize a new tenant
  this(UUID id, string name, string domain, string owner, Json settings) {
    this.id = id;
    this.name = name;
    this.domain = domain;
    this.owner = owner;
    this.createdAt = SysTime.nowUTC();
    this.updatedAt = SysTime.nowUTC();
    this.settings = settings;
  }

  UUID _id; // Unique identifier for the tenant
  UUID id() {
    return _id;
  }
  void id(UUID value) {
    _id = value;
  }

  string _name; // Name of the tenant  
  string name() {
    return _name;
  }
  void name(string value) {
    _name = value;
  }

  string _description; // Optional description of the tenant
  string description() {
    return _description;
  }
  void description(string value) {
    _description = value;
  }

  string _domain; // Custom domain associated with the tenant
  string domain() {
    return _domain;
  }
  void domain(string value) {
    _domain = value;
  }

  string _owner; // Owner of the tenant
  string owner() {
    return _owner;
  }
  void owner(string value) {
    _owner = value;
  }

  SysTime _createdAt; // Creation timestamp
  SysTime createdAt() {
    return _createdAt;
  }
  void createdAt(SysTime value) {
    _createdAt = value;
  }

  SysTime _updatedAt; // Last updated timestamp
  SysTime updatedAt() {
    return _updatedAt;
  }
  void updatedAt(SysTime value) {
    _updatedAt = value;
  }

  Json _settings; // Tenant-specific settings in JSON format
  Json settings() {
    return _settings;
  }
  void settings(Json value) {
    _settings = value;
  }

  bool isValid() {
    return validate();
  }
  
  bool validate() {
    // Basic validation logic for tenant properties
    if (id == null || name == "" || domain == "" || owner == "") {
      return false;
    }
    // Additional validation can be added here (e.g., domain format)
    return true;
  }

  // Method to update tenant settings
  void updateSettings(Json newSettings) {
    settings = newSettings;
    updatedAt = SysTime.nowUTC();
  }

  Json toJson() {
    return Json.empty
      .set("id", id.toString())
      .set("name", name)
      .set("description", description)
      .set("domain", domain)
      .set("owner", owner)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString())
      .set("settings", settings);
  }

  override string toString() {
    return "SAPTenant(id: " ~ id.toString() ~ ", name: " ~ name ~ ", domain: " ~ domain ~ ", owner: " ~ owner ~ ", createdAt: " ~ createdAt.toString() ~ ", updatedAt: " ~ updatedAt.toString() ~ ")";  
  }
}
