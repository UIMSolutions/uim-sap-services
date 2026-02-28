module uim.sap.aem.models.edacomponent;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


struct AEMEDAComponent {
  string tenantId;
  string componentId;
  string name;
  string componentType;
  string owner;
  string lifecycle = "active";
  SysTime updatedAt;

  Json toJson() const {
    Json resultJson = Json.emptyObject;
    resultJson["tenant_id"] = tenantId;
    resultJson["component_id"] = componentId;
    resultJson["name"] = name;
    resultJson["component_type"] = componentType;
    resultJson["owner"] = owner;
    resultJson["lifecycle"] = lifecycle;
    resultJson["updated_at"] = updatedAt.toISOExtString();
    return resultJson;
  }
}

AEMEDAComponent componentFromJson(string tenantId, Json request) {
  AEMEDAComponent component;
  component.tenantId = tenantId;
  component.componentId = randomUUID().toString();
  component.updatedAt = Clock.currTime();

  if ("component_id" in request && request["component_id"].type == Json.Type.string) {
    component.componentId = request["component_id"].get!string;
  }
  if ("name" in request && request["name"].type == Json.Type.string) {
    component.name = request["name"].get!string;
  }
  if ("component_type" in request && request["component_type"].type == Json.Type.string) {
    component.componentType = request["component_type"].get!string;
  }
  if ("owner" in request && request["owner"].type == Json.Type.string) {
    component.owner = request["owner"].get!string;
  }
  if ("lifecycle" in request && request["lifecycle"].type == Json.Type.string) {
    component.lifecycle = request["lifecycle"].get!string;
  }

  return component;
}
