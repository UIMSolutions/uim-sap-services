/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.eventmesh;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

/**
  * Represents an Event Mesh configuration for a tenant and broker service.
  * Contains details such as mesh ID, associated topics, and timestamps for creation and updates.
  *
  * The `AEMEventMesh` struct provides a method to convert its data into a JSON format suitable for API responses.
  * The `meshFromJson` function allows for the creation of an `AEMEventMesh` instance from a JSON request, ensuring that necessary fields are properly initialized and validated.
  * Fields:
  * - `tenantId`: The ID of the tenant this event mesh belongs to.
  * - `meshId`: The unique ID of the event mesh.
  * - `brokerServiceId`: The ID of the broker service associated with this event mesh.
  * - `name`: The name of the event mesh.
  * - `topics`: An array of topics associated with this event mesh.
  * - `createdAt`: The timestamp of when the event mesh was created.
  * - `updatedAt`: The timestamp of when the event mesh was last updated.
  * Methods:
  * - `toJson()`: Converts the event mesh instance to a JSON object for API responses.
  * - `meshFromJson(UUID tenantId, string brokerServiceId, Json request)`: Creates an instance of `AEMEventMesh` from a JSON request, initializing fields based
  *   on the provided data and generating a unique `meshId` if not provided.
  * Example usage:
  * ```
  * Json request = Json.emptyObject;
  * request["name"] = "Order Events Mesh";
  * request["topics"] = Json(["order.created", "order.updated"]);
  * AEMEventMesh eventMesh = meshFromJson("tenant123", "broker456", request);
  * Json response = eventMesh.toJson();
  * ```
  * Note: The example usage demonstrates how to create a new `AEMEventMesh` instance from a JSON request and then convert it back to JSON for an API response. The `mesh
FromJson` function ensures that the `tenantId` and `brokerServiceId` are set and that a unique `meshId` is generated if it is not included in the request. The `toJson` method provides a standardized way to serialize the event mesh's data for use in various parts of the application, such as API responses or database storage.
  */
class AEMEventMesh : SAPTenantObject {
  mixin(SAPObjectTemplate!AEMEventMesh);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("mesh_id" in initData && initData["mesh_id"].isString) {
      meshId = UUID(initData["mesh_id"].get!string);
    }

    if ("broker_service_id" in initData && initData["broker_service_id"].isString) {
      brokerServiceId = UUID(initData["broker_service_id"].get!string);
    }

    if ("name" in initData && initData["name"].isString) {
      name = initData["name"].getString;
    }
    
    if ("topics" in initData && initData["topics"].isArray) {
      foreach (topicJson; initData["topics"].toArray) {
        if (topicJson.isString) {
          topics ~= topicJson.getString;
        }
      }
    }

    return true;
  }

  UUID meshId;
  UUID brokerServiceId;
  string name;
  string[] topics;

  override override Json toJson() {
    auto topicsJson = topics.map!(topic => topic).array;

    return super.toJson()
      .set("mesh_id", meshId)
      .set("broker_service_id", brokerServiceId)
      .set("name", name)
      .set("topics", topicsJson);
  }
}

AEMEventMesh meshFromJson(UUID tenantId, UUID brokerServiceId, Json request) {
  AEMEventMesh mesh = new AEMEventMesh(request);

  mesh.tenantId = tenantId;
  mesh.meshId = randomUUID();
  mesh.brokerServiceId = brokerServiceId;
  mesh.createdAt = Clock.currTime();
  mesh.updatedAt = mesh.createdAt;

  return mesh;
}
