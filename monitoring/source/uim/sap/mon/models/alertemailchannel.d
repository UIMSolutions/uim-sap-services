/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.alertemailchannel;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

/**
  * Represents the configuration for the alert email channel, including whether it's enabled,
  * the list of recipient email addresses, the sender email address, and the subject prefix for alert emails.
  * Fields:
  * - enabled: A boolean indicating whether the alert email channel is enabled.
  * - recipients: An array of email addresses that will receive the alert emails.
  * - sender: The email address that will be used as the sender of the alert emails.     
  * - subjectPrefix: A string that will be prefixed to the subject of all alert emails sent through this channel.
  * - updatedAt: The timestamp of the last update to this configuration.
  */
struct MONAlertEmailChannel {
  bool enabled;
  string[] recipients;
  string sender;
  string subjectPrefix;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    Json recipientList = Json.emptyArray;
    foreach (item; recipients) {
      recipientList ~= item;
    }
    payload["enabled"] = enabled;
    payload["recipients"] = recipientList;
    payload["sender"] = sender;
    payload["subject_prefix"] = subjectPrefix;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
