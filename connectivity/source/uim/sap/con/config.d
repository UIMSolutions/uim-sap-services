/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.config;

import uim.sap.con;

mixin(ShowModule!());

@safe:

/**
  * The CONConfig class defines the configuration settings for the Connectivity (CON) service. It extends the SAPConfig base class and includes additional properties specific to the CON service, such as the connector location ID.
  * The configuration can be initialized from a JSON object, allowing for flexible and dynamic configuration management. The class also includes validation logic to ensure that required settings are properly set, such as the connector location ID, which must be a valid UUID.
  *
  * Example usage:
  * CONConfig config = new CONConfig();
  * config.initialize(jsonData);
  * config.validate();
  *
  * Configuration options include:
  * - Network settings: basePath, host, port
  * - Service settings: serviceName, serviceVersion
  * - Authentication settings: requireAuthToken, authToken
  * - Connector settings: connectorLocationId
  */
class CONConfig : SAPConfig {
  mixin(SAPConfigTemplate!CONConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    port(cast(ushort)initData.getInteger("port", 8085));
    basePath(initData.getString("basePath", "/api/con"));
    host(initData.getString("host", "0.0.0.0"));
    
    // Service metadata
    serviceName(initData.getString("serviceName", "uim-con"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    connectorLocationId(initData.getString("connectorLocationId", defaultLocationId.toString())); // "default-location"

    return true;
  }

  // #region Connector Location ID
  /**
   * The connector location ID is a unique identifier for the physical or logical location of the connector.
   * It is used to route requests to the appropriate connector instance based on its location.
   * This can be particularly useful in scenarios where multiple connectors are deployed across different regions or data centers.
   *
    * The connector location ID should be a valid UUID string. If an invalid UUID is provided, it will throw an exception during validation.
    *
    * Example usage:
    * config.connectorLocationId("123e4567-e89b-12d3-a456-426614174000");
    */
  protected UUID _connectorLocationId;
  void connectorLocationId(string id) {
    if (id.length > 0) {
      connectorLocationId(UUID(id));
    }
  }

  void connectorLocationId(UUID id) {
    _connectorLocationId = id;
  }

  UUID connectorLocationId() {
    return _connectorLocationId;
  }
  // #endregion Connector Location ID

  override void validate() {
    super.validate();

    if (connectorLocationId == NULLUUID) {
      throw new CONConfigurationException("Connector location ID cannot be empty");
    }
  }
}
