/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.iflow;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents an integration flow (iFlow) in the SAP Integration Suite.
  *
  * An iFlow defines the routing and processing logic for messages between a sender and a receiver. It includes details such as the protocol used, endpoint URL, message count, error count, and deployment status.
  *
  * The `INTIFlow` struct includes fields for tenant ID, iFlow ID, name, description, package ID, version, status, runtime environment, sender and receiver information, protocol, endpoint URL, message and error counts, deployment timestamp, and creation/update timestamps.
  *
  * The `toJson` method converts the iFlow instance into a JSON representation for easy serialization and communication with external systems.
  *
  * The `iflowFromJson` function creates an `INTIFlow` instance from a JSON request payload, allowing for easy instantiation from incoming data.
  * 
  * Statuses:
  * - draft: The iFlow is in draft status and not yet active.
  * - active: The iFlow is active and can process messages.
  * - error: The iFlow has encountered an error and cannot process messages.
  * - deployed: The iFlow has been deployed to the runtime environment.
  * 
  * Runtime Environments:
  * - cloud: The iFlow is designed to run in the cloud environment.
  * - hybrid: The iFlow is designed to run in a hybrid environment, which may include both cloud and on-premises components.
  * 
  * For more information on iFlows and their management, refer to the SAP Integration Suite documentation.
  */
class INTIFlow : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!INTIFlow);

  UUID iflowId;
  string name;
  string description;
  UUID packageId;
  string version_ = "1.0.0";
  string status = "draft"; // draft | active | error | deployed
  string runtime = "cloud"; // cloud | hybrid
  string sender;
  string receiver;
  string protocol = "https";
  string endpointUrl;
  long messageCount = 0;
  long errorCount = 0;
  string deployedAt;

  override Json toJson() {
    return super.toJson()
      .set("iflow_id", iflowId)
      .set("name", name)
      .set("description", description)
      .set("package_id", packageId)
      .set("version", version_)
      .set("status", status)
      .set("runtime", runtime)
      .set("sender", sender)
      .set("receiver", receiver)
      .set("protocol", protocol)
      .set("endpoint_url", endpointUrl)
      .set("message_count", messageCount)
      .set("error_count", errorCount)
      .set("deployed_at", deployedAt);
  }

  static INTIFlow iflowFromJson(UUID tenantId, Json request) {
    INTIFlow f = new INTIFlow(request);
    f.tenantId = tenantId;
    f.iflowId = randomUUID();

    if ("name" in request && request["name"].isString)
      f.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      f.description = request["description"].getString;
    if ("package_id" in request && request["package_id"].isString)
      f.packageId = request["package_id"].getString;
    if ("version" in request && request["version"].isString)
      f.version_ = request["version"].getString;
    if ("runtime" in request && request["runtime"].isString)
      f.runtime = request["runtime"].getString;
    if ("sender" in request && request["sender"].isString)
      f.sender = request["sender"].getString;
    if ("receiver" in request && request["receiver"].isString)
      f.receiver = request["receiver"].getString;
    if ("protocol" in request && request["protocol"].isString)
      f.protocol = request["protocol"].getString;
    if ("endpoint_url" in request && request["endpoint_url"].isString)
      f.endpointUrl = request["endpoint_url"].getString;

    f.createdAt = Clock.currTime().toINTOExtString();
    f.updatedAt = f.createdAt;
    return f;
  }
}
