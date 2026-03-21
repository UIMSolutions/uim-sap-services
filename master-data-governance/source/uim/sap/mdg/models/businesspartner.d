module uim.sap.mdg.models.businesspartner;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:
struct MDGBusinessPartner {
  UUID tenantId;
  string bpId;
  string externalId;
  string name;
  string country;
  string email;
  string phone;

  Json contactPersons;
  Json relationships;
  Json attributes;

  string workflowState = "draft";
  string approver;
  string sourceSystem = "manual";

  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["bp_id"] = bpId;
    payload["external_id"] = externalId;
    payload["name"] = name;
    payload["country"] = country;
    payload["email"] = email;
    payload["phone"] = phone;
    payload["contact_persons"] = contactPersons;
    payload["relationships"] = relationships;
    payload["attributes"] = attributes;
    payload["workflow_state"] = workflowState;
    payload["approver"] = approver;
    payload["source_system"] = sourceSystem;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

MDGBusinessPartner businessPartnerFromJson(UUID tenantId, Json request, string defaultApprover) {
  MDGBusinessPartner bp;
  bp.tenantId = UUID(tenantId);
  bp.bpId = randomUUID().toString();
  bp.createdAt = Clock.currTime();
  bp.updatedAt = bp.createdAt;
  bp.workflowState = "draft";
  bp.approver = defaultApprover;
  bp.contactPersons = Json.emptyArray;
  bp.relationships = Json.emptyArray;
  bp.attributes = Json.emptyObject;

  if ("bp_id" in request && request["bp_id"].isString) {
    bp.bpId = request["bp_id"].get!string;
  }
  if ("external_id" in request && request["external_id"].isString) {
    bp.externalId = request["external_id"].get!string;
  }
  if ("name" in request && request["name"].isString) {
    bp.name = request["name"].get!string;
  }
  if ("country" in request && request["country"].isString) {
    bp.country = request["country"].get!string;
  }
  if ("email" in request && request["email"].isString) {
    bp.email = request["email"].get!string;
  }
  if ("phone" in request && request["phone"].isString) {
    bp.phone = request["phone"].get!string;
  }
  if ("contact_persons" in request && request["contact_persons"].isArray) {
    bp.contactPersons = request["contact_persons"];
  }
  if ("relationships" in request && request["relationships"].isArray) {
    bp.relationships = request["relationships"];
  }
  if ("attributes" in request && request["attributes"].isObject) {
    bp.attributes = request["attributes"];
  }
  if ("workflow_state" in request && request["workflow_state"].isString) {
    bp.workflowState = normalizeWorkflowState(request["workflow_state"].get!string);
  }
  if ("approver" in request && request["approver"].isString) {
    bp.approver = request["approver"].get!string;
  }
  if ("source_system" in request && request["source_system"].isString) {
    bp.sourceSystem = request["source_system"].get!string;
  }

  return bp;
}
