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
struct INTIFlow {
  UUID tenantId;
  string iflowId;
  string name;
  string description;
  string packageId;
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
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    return super.toJson()
    j["tenant_id"] = tenantId;
    j["iflow_id"] = iflowId;
    j["name"] = name;
    j["description"] = description;
    j["package_id"] = packageId;
    j["version"] = version_;
    j["status"] = status;
    j["runtime"] = runtime;
    j["sender"] = sender;
    j["receiver"] = receiver;
    j["protocol"] = protocol;
    j["endpoint_url"] = endpointUrl;
    j["message_count"] = messageCount;
    j["error_count"] = errorCount;
    j["deployed_at"] = deployedAt;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTIFlow iflowFromJson(UUID tenantId, Json request) {
  INTIFlow f;
  f.tenantId = UUID(tenantId);
  f.iflowId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    f.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    f.description = request["description"].get!string;
  if ("package_id" in request && request["package_id"].isString)
    f.packageId = request["package_id"].get!string;
  if ("version" in request && request["version"].isString)
    f.version_ = request["version"].get!string;
  if ("runtime" in request && request["runtime"].isString)
    f.runtime = request["runtime"].get!string;
  if ("sender" in request && request["sender"].isString)
    f.sender = request["sender"].get!string;
  if ("receiver" in request && request["receiver"].isString)
    f.receiver = request["receiver"].get!string;
  if ("protocol" in request && request["protocol"].isString)
    f.protocol = request["protocol"].get!string;
  if ("endpoint_url" in request && request["endpoint_url"].isString)
    f.endpointUrl = request["endpoint_url"].get!string;

  f.createdAt = Clock.currTime().toINTOExtString();
  f.updatedAt = f.createdAt;
  return f;
}
