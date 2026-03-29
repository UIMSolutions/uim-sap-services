module uim.sap.mdg.models.businesspartner;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:
class MDGBusinessPartner : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!MDGBusinessPartner);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("bp_id" in initData && initData["bp_id"].isString) {
      bpId = UUID(initData["bp_id"].get!string);
    }

    if ("external_id" in initData && initData["external_id"].isString) {
      externalId = UUID(initData["external_id"].get!string);
    }

    name = initData.getString("name");
    country = initData.getString("country");
    email = initData.getString("email");
    phone = initData.getString("phone");

    bp.contactPersons = Json.emptyArray;
    if ("contact_persons" in initData && initData["contact_persons"].isArray) {
      contactPersons = initData["contact_persons"];
    }

    bp.relationships = Json.emptyArray;
    if ("relationships" in initData && initData["relationships"].isArray) {
      relationships = initData["relationships"];
    }

    bp.attributes = Json.emptyObject;
    if ("attributes" in initData && initData["attributes"].isObject) {
      attributes = initData["attributes"];
    }

    if ("workflow_state" in initData && initData["workflow_state"].isString) {
      workflowState = normalizeWorkflowState(initData["workflow_state"].get!string);
    }

    approver = initData.getString("approver");
    sourceSystem = initData.getString("source_system");

    return true;
  }

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

  override Json toJson() {
    return super.toJson
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
      .set("source_system", sourceSystem);
  }

  static MDGBusinessPartner opCall(UUID tenantId, Json request, string defaultApprover) {
    MDGBusinessPartner bp = new MDGBusinessPartner(request);
    bp.tenantId = tenantId;
    bp.bpId = randomUUID();
    bp.createdAt = Clock.currTime();
    bp.updatedAt = bp.createdAt;
    bp.workflowState = "draft";
    bp.approver = defaultApprover;

    return bp;
  }
}
