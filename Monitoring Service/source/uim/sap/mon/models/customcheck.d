module uim.sap.mon.models.customcheck;

import uim.sap.mon;

@safe:

struct MONCustomCheck {
    string checkId;
    string name;
    string targetType;
    string targetId;
    string endpoint;
    string method;
    int expectedStatus;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["check_id"] = checkId;
        payload["name"] = name;
        payload["target_type"] = targetType;
        payload["target_id"] = targetId;
        payload["endpoint"] = endpoint;
        payload["method"] = method;
        payload["expected_status"] = expectedStatus;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}