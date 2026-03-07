module uim.sap.mgt.service;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/**
  * Service layer for Management service
  *
  * This class is responsible for handling all business logic related to Management.
  * It interacts with the BTP client to fetch data and perform operations on the BTP environment.
  * The service layer abstracts away the complexities of the underlying BTP client and provides a simple interface for the server layer to interact with.
  * It includes methods for health checks, readiness checks, and various operations related to environments, subaccounts, organizations, spaces, applications, services, service instances, and destinations.
  * 
  * Example usage:
  * MGTConfig config = MGTConfig(
  *     serviceName: "My Management Service",
  *     serviceVersion: "1.0.0",
  *     subdomain: "my-subdomain",
  *     region: "api.sap.hana.ondemand.com",
  *     useOAuth2: true,
  *     clientId: "my-client-id",
  *     clientSecret: "my-client-secret"
  * );
  * MGTService service = new MGTService(config);
  */ 
class MGTService : SAPService {
  mixin(SAPServiceTemplate!MGTService);

  private MGTConfig _config;
  private BTPClient _client;

  this(MGTConfig config) {
    config.validate();
    _config = config;
    _client = new BTPClient(config.toBTPConfig());
  }

  @property const(MGTConfig) config() const {
    return _config;
  }

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["ok"] = true;
    healthInfo["serviceName"] = _config.serviceName;
    healthInfo["serviceVersion"] = _config.serviceVersion;
    healthInfo["subdomain"] = _config.subdomain;
    healthInfo["region"] = _config.region;
    return healthInfo;
  }

  Json environments() {
    return toVibeJson(getEnvironment(_client));
  }

  Json subaccounts() {
    return toVibeJson(getSubaccounts(_client));
  }

  Json organizations() {
    return toVibeJson(listOrganizations(_client));
  }

  Json spaces() {
    return toVibeJson(listSpaces(_client));
  }

  Json applications() {
    return toVibeJson(listApplications(_client));
  }

  Json application(string guid) {
    if (guid.length == 0) {
      throw new MGTUpstreamException("Application GUID cannot be empty");
    }
    return toVibeJson(getApplication(_client, guid));
  }

  Json services() {
    return toVibeJson(listServices(_client));
  }

  Json serviceInstances() {
    return toVibeJson(listServiceInstances(_client));
  }

  Json destinations() {
    return toVibeJson(listDestinations(_client));
  }

  Json destination(string name) {
    if (name.length == 0) {
      throw new MGTUpstreamException("Destination name cannot be empty");
    }
    return toVibeJson(getDestination(_client, name));
  }

  private Json toVibeJson(StdJson payload) {
    return parseJsonString(payload.toString());
  }
}
