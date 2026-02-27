module uim.sap.btp.resources;

import std.json : JSONValue;
import std.string : format;

import uim.sap.btp.client;
import uim.sap.btp.config;

// Cloud Foundry Operations

JSONValue listApplications(BTPClient client) {
  return client.getApplications();
}

JSONValue listSpaces(BTPClient client) {
  return client.getSpaces();
}

JSONValue listOrganizations(BTPClient client) {
  return client.getOrganizations();
}

JSONValue listServices(BTPClient client) {
  return client.get("/v2/services", null, "cf");
}

JSONValue listServiceInstances(BTPClient client) {
  return client.get("/v2/service_instances", null, "cf");
}

JSONValue getApplication(BTPClient client, string appGuid) {
  auto path = format("/v2/apps/%s", appGuid);
  return client.get(path, null, "cf");
}

// Destination Operations

JSONValue listDestinations(BTPClient client) {
  return client.get("/destination-configuration/v1/destinations", null, "service");
}

JSONValue getDestination(BTPClient client, string destinationName) {
  auto path = format("/destination-configuration/v1/destinations/%s", destinationName);
  return client.get(path, null, "service");
}

// Environment Operations

JSONValue getEnvironment(BTPClient client) {
  return client.get("/platform/v1/environments", null);
}

JSONValue getSubaccounts(BTPClient client) {
  return client.get("/accounts/v1/subaccounts", null);
}
