/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.event_subscription;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTEventSubscription {
    string tenantId;
    string subscriptionId;
    string topicName;
    string callbackUrl;
    string deliveryMode = "push";   // push | pull
    bool active = true;
    long deliveredCount = 0;
    long failedCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["subscription_id"] = subscriptionId;
        j["topic_name"] = topicName;
        j["callback_url"] = callbackUrl;
        j["delivery_mode"] = deliveryMode;
        j["active"] = active;
        j["delivered_count"] = deliveredCount;
        j["failed_count"] = failedCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

INTEventSubscription eventSubscriptionFromJson(string tenantId, Json request) {
    INTEventSubscription s;
    s.tenantId = tenantId;
    s.subscriptionId = randomUUID().toString();

    if ("topic_name" in request && request["topic_name"].isString)
        s.topicName = request["topic_name"].get!string;
    if ("callback_url" in request && request["callback_url"].isString)
        s.callbackUrl = request["callback_url"].get!string;
    if ("delivery_mode" in request && request["delivery_mode"].isString)
        s.deliveryMode = request["delivery_mode"].get!string;

    s.createdAt = Clock.currTime().toINTOExtString();
    s.updatedAt = s.createdAt;
    return s;
}
