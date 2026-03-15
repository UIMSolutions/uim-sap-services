module uim.sap.atp.models.command;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPCommand {
  UUID tenantId;
  UUID commandId;
  UUID catalogId;
  string name;
  string description;
  string commandType;
  string[] steps;
  bool allowPrivateEnvironment;
  Json defaults;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["command_id"] = commandId;
    payload["catalog_id"] = catalogId;
    payload["name"] = name;
    payload["description"] = description;
    payload["command_type"] = commandType;
    Json stepValues = Json.emptyArray;
    foreach (step; steps)
      stepValues ~= step;
    payload["steps"] = stepValues;
    payload["allow_private_environment"] = allowPrivateEnvironment;
    payload["defaults"] = defaults;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
