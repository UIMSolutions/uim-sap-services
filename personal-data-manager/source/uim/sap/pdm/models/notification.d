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
class PDMNotification : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!PDMNotification);

    UUID notificationId;
    UUID subjectId;
    UUID requestId;        // optional: linked to a data request

    PDMNotificationChannel channel = PDMNotificationChannel.email;
    PDMNotificationStatus status = PDMNotificationStatus.pending;

    string recipient;        // email address or portal user
    string subject;          // notification subject line
    string body_;            // notification body content
    UUID templateId;       // optional template reference

    SysTime createdAt;
    SysTime sentAt;

    override Json toJson()  {
        Json json = super.toJson()
        .set("notification_id", notificationId)
        .set("subject_id", subjectId)
        .set("request_id", requestId)
        .set("channel", cast(string) channel)
        .set("status", cast(string) status)
        .set("recipient", recipient)
        .set("subject", subject)
        .set("body", body_)
        .set("template_id", templateId);

        return status != PDMNotificationStatus.pending
          ? json.set("sent_at", sentAt.toISOExtString()) : json;
    }
}

PDMNotification notificationFromJson(UUID notificationId, UUID subjectId, UUID tenantId, Json req) {
    PDMNotification n;
    n.notificationId = notificationId;
    n.subjectId = subjectId;
    n.tenantId = tenantId;
    n.createdAt = Clock.currTime();

    if ("request_id" in req && req["request_id"].isString)
        n.requestId = UUID(req["request_id"].get!string);
    if ("channel" in req && req["channel"].isString)
        n.channel = parseNotificationChannel(req["channel"].get!string);
    if ("recipient" in req && req["recipient"].isString)
        n.recipient = req["recipient"].getString;
    if ("subject" in req && req["subject"].isString)
        n.subject = req["subject"].getString;
    if ("body" in req && req["body"].isString)
        n.body_ = req["body"].getString;
    if ("template_id" in req && req["template_id"].isString)
        n.templateId = UUID(req["template_id"].get!string);

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
