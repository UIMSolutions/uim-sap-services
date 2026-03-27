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

  private BTPClient _client;

  this(MGTConfig config) {
    super(config);

    _client = new BTPClient(config.toBTPConfig());
  }

  override Json health() {
    auto cfg = cast(MGTConfig)config();
    return super.health()
      .set("subdomain", cfg.subdomain)
      .set("region", cfg.region);
  }

  Json environments() {
    return getEnvironment(_client).toJson;
  }

  Json subaccounts() {
    return getSubaccounts(_client).toJson;
  }

  Json organizations() {
    return listOrganizations(_client).toJson;
  }

  Json spaces() {
    return listSpaces(_client).toJson;
  }

  Json applications() {
    return listApplications(_client).toJson;
  }

  Json application(string guid) {
    if (guid.length == 0) {
      throw new MGTUpstreamException("Application GUID cannot be empty");
    }
    return getApplication(_client, guid).toJson;
  }

  Json services() {
    return listServices(_client).toJson;
  }

  Json serviceInstances() {
    return listServiceInstances(_client).toJson;
  }

  Json destinations() {
    return listDestinations(_client).toJson;
  }

  Json destination(string name) {
    if (name.length == 0) {
      throw new MGTUpstreamException("Destination name cannot be empty");
    }
    return getDestination(_client, name).toJson;
  }
}
