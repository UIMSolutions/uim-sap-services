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
    return super.toJson()
      .set("id", id)
      .set("situation_type", situationType)
      .set("template_id", templateId)
      .set("entity_type", entityType)
      .set("entity_id", entityId)
      .set("status", situationStatusToString(status))
      .set("resolution_flow", resolutionFlow)
      .set("data_context", dataContext)
      .set("occurred_at", occurredAt.toISOExtString())
      .set("resolved_at", resolvedAt != SysTime.init ? resolvedAt.toISOExtString() : "");    
  }
}

SituationInstance situationFromJson(Json payload, UUID tenantId) {
  SituationInstance instance;
  instance.id = randomUUID().toString();
  instance.tenantId = tenantId;
  instance.situationType = getString(payload, "situation_type", "");
  instance.templateId = getString(payload, "template_id", "");
  instance.entityType = getString(payload, "entity_type", "unknown");
  instance.entityId = getString(payload, "entity_id", randomUUID().toString());
  instance.status = situationStatusFromString(getString(payload, "status", "open"));
  instance.resolutionFlow = getString(payload, "resolution_flow", "manual_review");
  instance.occurredAt = Clock.currTime();
  instance.dataContext = payload.getObject("data_context", Json.emptyObject);

  if (instance.status != SituationStatus.open) {
    instance.resolvedAt = Clock.currTime();
  }

  return instance;
}