module uim.sap.isa.models.situationinstance;
import uim.sap.isa;

mixin(ShowModule!());

@safe:
class SituationInstance : SAPTenantObject {
  mixin(SAPObjectTemplate!SituationInstance);

  UUID id;
  string situationType;
  UUID templateId;
  string entityType;
  UUID entityId;
  SituationStatus status;
  string resolutionFlow;
  Json dataContext;
  SysTime occurredAt;
  SysTime resolvedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["id"] = id;
    payload["situation_type"] = situationType;
    payload["template_id"] = templateId;
    payload["entity_type"] = entityType;
    payload["entity_id"] = entityId;
    payload["status"] = situationStatusToString(status);
    payload["resolution_flow"] = resolutionFlow;
    payload["data_context"] = dataContext;
    payload["occurred_at"] = occurredAt.toISOExtString();
    if (resolvedAt != SysTime.init) {
      payload["resolved_at"] = resolvedAt.toISOExtString();
    } else {
      payload["resolved_at"] = "";
    }
    return payload;
  }
}

SituationInstance situationFromJson(Json payload, UUID tenantId) {
  SituationInstance instance;
  instance.id = randomUUID().toString();
  instance.tenantId = UUID(tenantId);
  instance.situationType = getString(payload, "situation_type", "");
  instance.templateId = getString(payload, "template_id", "");
  instance.entityType = getString(payload, "entity_type", "unknown");
  instance.entityId = getString(payload, "entity_id", randomUUID().toString());
  instance.status = situationStatusFromString(getString(payload, "status", "open"));
  instance.resolutionFlow = getString(payload, "resolution_flow", "manual_review");
  instance.occurredAt = Clock.currTime();

  if ("data_context" in payload && payload["data_context"].isObject) {
    instance.dataContext = payload["data_context"];
  } else {
    instance.dataContext = Json.emptyObject;
  }

  if (instance.status != SituationStatus.open) {
    instance.resolvedAt = Clock.currTime();
  }

  return instance;
}