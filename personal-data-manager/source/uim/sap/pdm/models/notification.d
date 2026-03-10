/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.models.notification;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Notification sent to a data subject about their personal data
struct PDMNotification {
    string notificationId;
    string subjectId;
    string tenantId;
    string requestId;        // optional: linked to a data request

    PDMNotificationChannel channel = PDMNotificationChannel.email;
    PDMNotificationStatus status = PDMNotificationStatus.pending;

    string recipient;        // email address or portal user
    string subject;          // notification subject line
    string body_;            // notification body content
    string templateId;       // optional template reference

    SysTime createdAt;
    SysTime sentAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["notification_id"] = notificationId;
        j["subject_id"] = subjectId;
        j["tenant_id"] = tenantId;
        j["request_id"] = requestId;
        j["channel"] = cast(string) channel;
        j["status"] = cast(string) status;
        j["recipient"] = recipient;
        j["subject"] = subject;
        j["body"] = body_;
        j["template_id"] = templateId;
        j["created_at"] = createdAt.toISOExtString();
        if (status != PDMNotificationStatus.pending)
            j["sent_at"] = sentAt.toISOExtString();
        return j;
    }
}

PDMNotification notificationFromJson(string notificationId, string subjectId, string tenantId, Json req) {
    PDMNotification n;
    n.notificationId = notificationId;
    n.subjectId = subjectId;
    n.tenantId = tenantId;
    n.createdAt = Clock.currTime();

    if ("request_id" in req && req["request_id"].isString)
        n.requestId = req["request_id"].get!string;
    if ("channel" in req && req["channel"].isString)
        n.channel = parseNotificationChannel(req["channel"].get!string);
    if ("recipient" in req && req["recipient"].isString)
        n.recipient = req["recipient"].get!string;
    if ("subject" in req && req["subject"].isString)
        n.subject = req["subject"].get!string;
    if ("body" in req && req["body"].isString)
        n.body_ = req["body"].get!string;
    if ("template_id" in req && req["template_id"].isString)
        n.templateId = req["template_id"].get!string;

    return n;
}

private PDMNotificationChannel parseNotificationChannel(string s) {
    switch (s) {
        case "email": return PDMNotificationChannel.email;
        case "portal": return PDMNotificationChannel.portal;
        case "api": return PDMNotificationChannel.api;
        default: return PDMNotificationChannel.email;
    }
}
