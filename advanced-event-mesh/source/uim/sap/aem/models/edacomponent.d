/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.edacomponent;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

/**
  * Represents an Event-Driven Architecture (EDA) component in the Advanced Event Mesh (AEM) system.
  * This struct is used to model the properties of an EDA component, including its tenant association,
  * unique identifier, name, type, owner, lifecycle status, and last update timestamp.
  *
  * The `toJson` method allows for easy serialization of the component's data into a JSON format,
  * which can be used for API responses or storage in a database. The `componentFrom
Json` function provides a way to create an instance of `AEMEDAComponent` from a JSON request, ensuring that all necessary fields are properly initialized and validated
  * before being used in the application.
  *
  * Fields:
  * - `tenantId`: The ID of the tenant this component belongs to.
  * - `componentId`: The unique ID of the component.
  * - `name`: The name of the component.
  * - `componentType`: The type of the component (e.g., "producer", "consumer", "processor").
  * - `owner`: The owner of the component.
  * - `lifecycle`: The lifecycle status of the component (e.g., "active", "inactive", "deprecated").
  * - `updatedAt`: The timestamp of when the component was last updated.
  * Methods:
  * - `toJson()`: Converts the component instance to a JSON object for API responses.
  * - `componentFromJson(UUID tenantId, Json request)`: Creates an instance of `AEMEDAComponent` from a JSON request, initializing fields based on the provided data and
  *   generating a unique `componentId` if not provided.
  * Example usage:
  * ```
  * Json request = Json.emptyObject;
  * request["name"] = "Order Service";
  * request["component_type"] = "producer";
  * request["owner"] = "team-a";
  * request["lifecycle"] = "active";
  * AEMEDAComponent component = componentFromJson("tenant123", request);
  * Json response = component.toJson();
  * ```
  * Note: The example usage demonstrates how to create a new `AEMEDAComponent` instance from a JSON request and then convert it back to JSON for an API response. The `component
FromJson` function ensures that the `tenantId` is set and that a unique `componentId` is generated if it is not included in the request. The `toJson` method provides a standardized way to serialize the component's data for use in various parts of the application, such as API responses or database storage.
  */
  class AEMEDAComponent : SAPTenantObject {
    mixin(SAPObjectTemplate!AEMEDAComponent);

  UUID componentId;
  string name;
  string componentType;
  string owner;
  string lifecycle = "active";

  override override Json toJson()  {
    return super.toJson()
    .set("component_id", componentId)
    .set("name", name)
    .set("component_type", componentType)
    .set("owner", owner)
    .set("lifecycle", lifecycle);
  }
}

AEMEDAComponent componentFromJson(UUID tenantId, Json request) {
  AEMEDAComponent component = new AEMEDAComponent();
  component.tenantId = tenantId;
  component.componentId = randomUUID();
  component.updatedAt = Clock.currTime();

  if ("component_id" in request && request["component_id"].isString) {
    component.componentId = request["component_id"].get!string;
  }
  if ("name" in request && request["name"].isString) {
    component.name = request["name"].get!string;
  }
  if ("component_type" in request && request["component_type"].isString) {
    component.componentType = request["component_type"].get!string;
  }
  if ("owner" in request && request["owner"].isString) {
    component.owner = request["owner"].get!string;
  }
  if ("lifecycle" in request && request["lifecycle"].isString) {
    component.lifecycle = request["lifecycle"].get!string;
  }

  return component;
}
