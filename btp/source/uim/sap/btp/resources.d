module uim.sap.btp.resources;

import std.json : JSONValue;
import std.string : format;

import uim.sap.btp.client;
import uim.sap.btp.config;

// Cloud Foundry Operations

JSONValue listApplications(SAPBTPClient client) {
  return client.getApplications();
}

JSONValue listSpaces(SAPBTPClient client) {
  return client.getSpaces();
}

JSONValue listOrganizations(SAPBTPClient client) {
  return client.getOrganizations();
}

JSONValue listServices(SAPBTPClient client) {
  return client.get("/v2/services", null, "cf");
}

JSONValue listServiceInstances(SAPBTPClient client) {
  return client.get("/v2/service_instances", null, "cf");
}

JSONValue getApplication(SAPBTPClient client, string appGuid) {
  auto path = format("/v2/apps/%s", appGuid);
  return client.get(path, null, "cf");
}

// Destination Operations

JSONValue listDestinations(SAPBTPClient client) {
  return client.get("/destination-configuration/v1/destinations", null, "service");
}

JSONValue getDestination(SAPBTPClient client, string destinationName) {
  auto path = format("/destination-configuration/v1/destinations/%s", destinationName);
  return client.get(path, null, "service");
}

// Environment Operations

JSONValue getEnvironment(SAPBTPClient client) {
  return client.get("/platform/v1/environments", null);
}

JSONValue getSubaccounts(SAPBTPClient client) {
  return client.get("/accounts/v1/subaccounts", null);
}
