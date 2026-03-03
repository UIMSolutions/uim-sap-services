module uim.sap.identityprovisioning.models.notification;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A notification subscription for provisioning job events.
 *
 *  Subscribers receive status updates when provisioning jobs
 *  start, complete, or fail on a given source system.
 *
 *  `eventTypes` values: "job.started", "job.completed", "job.failed", "job.cancelled"
 */
struct IPNotification {
    string tenantId;
    string subscriptionId;
    string sourceSystemId;
    string callbackUrl;
    string[] eventTypes;     // e.g., ["job.started", "job.completed", "job.failed"]
    bool active = true;
    long deliveredCount = 0;
    long failedCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["subscription_id"] = subscriptionId;
        j["source_system_id"] = sourceSystemId;
        j["callback_url"] = callbackUrl;

        Json events = Json.emptyArray;
        foreach (evt; eventTypes) {
            events ~= Json(evt);
        }
        j["event_types"] = events;

        j["active"] = active;
        j["delivered_count"] = deliveredCount;
        j["failed_count"] = failedCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

IPNotification notificationFromJson(string tenantId, Json request) {
    IPNotification n;
    n.tenantId = tenantId;
    n.subscriptionId = randomUUID().toString();

    if ("source_system_id" in request && request["source_system_id"].type == Json.Type.string)
        n.sourceSystemId = request["source_system_id"].get!string;
    if ("callback_url" in request && request["callback_url"].type == Json.Type.string)
        n.callbackUrl = request["callback_url"].get!string;
    if ("active" in request && request["active"].type == Json.Type.bool_)
        n.active = request["active"].get!bool;
    if ("subscription_id" in request && request["subscription_id"].type == Json.Type.string)
        n.subscriptionId = request["subscription_id"].get!string;

    if ("event_types" in request && request["event_types"].type == Json.Type.array) {
        foreach (item; request["event_types"]) {
            if (item.type == Json.Type.string)
                n.eventTypes ~= item.get!string;
        }
    }

    n.createdAt = Clock.currTime().toISOExtString();
    n.updatedAt = n.createdAt;
    return n;
}
