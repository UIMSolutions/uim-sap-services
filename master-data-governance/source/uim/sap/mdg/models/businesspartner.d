module uim.sap.mdg.models.businesspartner;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:
struct MDGBusinessPartner {
  UUID tenantId;
  UUID bpId;
  UUID externalId;
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
    return super.toJson
    .set("tenant_id", tenantId)
    .set("bp_id", bpId)
    .set("external_id", externalId)
    .set("name", name)
    .set("country", country)
    .set("email", email)
    .set("phone", phone)
    .set("contact_persons", contactPersons)
    .set("relationships", relationships)
    .set("attributes", attributes)
    .set("workflow_state", workflowState)
    .set("approver", approver)
    .set("source_system", sourceSystem)
    .set("created_at", createdAt.toISOExtString())
    .set("updated_at", updatedAt.toISOExtString());
  }
}

MDGBusinessPartner businessPartnerFromJson(UUID tenantId, Json request, string defaultApprover) {
  MDGBusinessPartner bp = new MDGBusinessPartner(request);
  bp.tenantId = tenantId;
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
