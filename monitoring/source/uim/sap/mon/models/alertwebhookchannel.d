/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.alertwebhookchannel;

import uim.sap.mon;

mixin(ShowModule!());

@safe:


/**
 * Represents the configuration for an alert webhook channel.
 * Fields:
 * - enabled: A boolean indicating whether the alert webhook channel is enabled.
 * - url: The URL to which alert notifications will be sent when triggered.
 * - secret: A secret token used for authenticating the webhook requests.
 * - method: The HTTP method to use when sending alert notifications (default is "POST").
 * - updatedAt: The timestamp of the last update to this configuration.
 *
 * This struct is used to store and manage the configuration settings for sending alert notifications via webhooks.
 * When an alert is triggered, the monitoring service will send a request to the specified URL using the configured HTTP method and include the secret token for authentication.
 * The enabled field allows for easily turning the webhook notifications on or off without needing to delete the configuration.
 * The updatedAt field helps track when the configuration was last modified, which can be useful for auditing and troubleshooting purposes.
 * 
 * Note: The secret token should be kept secure and not exposed in logs or error messages, as it is used to authenticate the webhook requests and prevent unauthorized access.
 * 
 * Example usage:
 *   MONAlertWebhookChannel webhookConfig;
 *   webhookConfig.enabled = true;
 *   webhookConfig.url = "https://example.com/alert-webhook";
 *   webhookConfig.secret = "supersecret";
 *   webhookConfig.method = "POST";
 *   webhookConfig.updatedAt = Clock.currTime();  
 */
class MONAlertWebhookChannel : SAPEntity {
  mixin(SAPEntityTemplate!MONAlertWebhookChannel);

  bool enabled;
  string url;
  string secret;
  string method = "POST";

  override Json toJson()  {
    return super.toJson
    .set("enabled", enabled)
    .set("url", url)
    .set("method", method)
    .set("secret", secret);
  }
}
