module uim.sap.cdm.repositories.custom_domain;

import models.custom_domain;
import std.json;
import std.file;
import std.stdio;

class CustomDomainRepository {
  private string dataFilePath;

  this(string filePath) {
    dataFilePath = filePath;
  }

  // Function to load custom domains from a JSON file
  public CustomDomain[] loadCustomDomains() {
    if (!exists(dataFilePath)) {
      return null;
    }

    auto jsonData = readText(dataFilePath);
    auto jsonArray = parseJSON(jsonData).array;
    CustomDomain[] customDomains;

    foreach (jsonDomain; jsonArray) {
      customDomains ~= CustomDomain(jsonDomain);
    }

    return customDomains;
  }

  // Function to save custom domains to a JSON file
  public void saveCustomDomains(CustomDomain[] customDomains) {
    auto jsonArray = JsonArray();

    foreach (domain; customDomains) {
      jsonArray ~= domain.toJson();
    }

    writeText(dataFilePath, jsonArray.toString());
  }

  // Function to find a custom domain by its name
  public CustomDomain findByName(string name) {
    auto domains = loadCustomDomains();
    foreach (domain; domains) {
      if (domain.name == name) {
        return domain;
      }
    }
    return null;
  }

  // Function to add a new custom domain
  public void addCustomDomain(CustomDomain newDomain) {
    auto domains = loadCustomDomains();
    domains ~= newDomain;
    saveCustomDomains(domains);
  }

  // Function to remove a custom domain by its name
  public void removeCustomDomain(string name) {
    auto domains = loadCustomDomains();
    domains = domains.filter!(d => d.name != name);
    saveCustomDomains(domains);
  }
}
