module uim.sap.mdg.models;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.datetime : Clock, SysTime;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

enum string[] MDG_WORKFLOW_STATES = ["draft", "in_review", "approved", "rejected"];

string normalizeWorkflowState(string state) {
    return toLower(state);
}

bool isValidWorkflowState(string state) {
    return MDG_WORKFLOW_STATES.canFind(normalizeWorkflowState(state));
}

struct MDGBusinessPartner {
    string tenantId;
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

    Json toJson() const {
        Json payload = Json.emptyObject;
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

struct MDGQualityRule {
    string tenantId;
    string ruleId;
    string name;
    string field;
    string ruleType;
    bool enabled = true;
    Json options;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["rule_id"] = ruleId;
        payload["name"] = name;
        payload["field"] = field;
        payload["rule_type"] = ruleType;
        payload["enabled"] = enabled;
        payload["options"] = options;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct MDGConsolidationCandidate {
    string tenantId;
    string primaryBpId;
    string duplicateBpId;
    long score;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["primary_bp_id"] = primaryBpId;
        payload["duplicate_bp_id"] = duplicateBpId;
        payload["score"] = score;
        return payload;
    }
}

MDGBusinessPartner businessPartnerFromJson(string tenantId, Json request, string defaultApprover) {
    MDGBusinessPartner bp;
    bp.tenantId = tenantId;
    bp.bpId = randomUUID().toString();
    bp.createdAt = Clock.currTime();
    bp.updatedAt = bp.createdAt;
    bp.workflowState = "draft";
    bp.approver = defaultApprover;
    bp.contactPersons = Json.emptyArray;
    bp.relationships = Json.emptyArray;
    bp.attributes = Json.emptyObject;

    if ("bp_id" in request && request["bp_id"].type == Json.Type.string) {
        bp.bpId = request["bp_id"].get!string;
    }
    if ("external_id" in request && request["external_id"].type == Json.Type.string) {
        bp.externalId = request["external_id"].get!string;
    }
    if ("name" in request && request["name"].type == Json.Type.string) {
        bp.name = request["name"].get!string;
    }
    if ("country" in request && request["country"].type == Json.Type.string) {
        bp.country = request["country"].get!string;
    }
    if ("email" in request && request["email"].type == Json.Type.string) {
        bp.email = request["email"].get!string;
    }
    if ("phone" in request && request["phone"].type == Json.Type.string) {
        bp.phone = request["phone"].get!string;
    }
    if ("contact_persons" in request && request["contact_persons"].type == Json.Type.array) {
        bp.contactPersons = request["contact_persons"];
    }
    if ("relationships" in request && request["relationships"].type == Json.Type.array) {
        bp.relationships = request["relationships"];
    }
    if ("attributes" in request && request["attributes"].type == Json.Type.object) {
        bp.attributes = request["attributes"];
    }
    if ("workflow_state" in request && request["workflow_state"].type == Json.Type.string) {
        bp.workflowState = normalizeWorkflowState(request["workflow_state"].get!string);
    }
    if ("approver" in request && request["approver"].type == Json.Type.string) {
        bp.approver = request["approver"].get!string;
    }
    if ("source_system" in request && request["source_system"].type == Json.Type.string) {
        bp.sourceSystem = request["source_system"].get!string;
    }

    return bp;
}

MDGQualityRule qualityRuleFromJson(string tenantId, string ruleId, Json request) {
    MDGQualityRule rule;
    rule.tenantId = tenantId;
    rule.ruleId = ruleId;
    rule.updatedAt = Clock.currTime();
    rule.options = Json.emptyObject;

    if ("name" in request && request["name"].type == Json.Type.string) {
        rule.name = request["name"].get!string;
    }
    if ("field" in request && request["field"].type == Json.Type.string) {
        rule.field = request["field"].get!string;
    }
    if ("rule_type" in request && request["rule_type"].type == Json.Type.string) {
        rule.ruleType = toLower(request["rule_type"].get!string);
    }
    if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
        rule.enabled = request["enabled"].get!bool;
    }
    if ("options" in request && request["options"].type == Json.Type.object) {
        rule.options = request["options"];
    }

    return rule;
}

MDGConsolidationCandidate[] detectDuplicateCandidates(string tenantId, MDGBusinessPartner[] businessPartners) {
    auto builder = appender!(MDGConsolidationCandidate[])();

    for (size_t i = 0; i < businessPartners.length; ++i) {
        for (size_t j = i + 1; j < businessPartners.length; ++j) {
            auto a = businessPartners[i];
            auto b = businessPartners[j];

            long score = 0;
            if (a.name.length > 0 && b.name.length > 0 && toLower(a.name) == toLower(b.name)) {
                score += 60;
            }
            if (a.email.length > 0 && b.email.length > 0 && toLower(a.email) == toLower(b.email)) {
                score += 25;
            }
            if (a.phone.length > 0 && b.phone.length > 0 && a.phone == b.phone) {
                score += 15;
            }

            if (score >= 60) {
                MDGConsolidationCandidate candidate;
                candidate.tenantId = tenantId;
                candidate.primaryBpId = a.bpId;
                candidate.duplicateBpId = b.bpId;
                candidate.score = score;
                builder.put(candidate);
            }
        }
    }

    return builder.data;
}
