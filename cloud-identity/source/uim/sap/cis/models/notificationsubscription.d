/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.notificationsubscription;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Model representing a notification subscription in the UIM Cloud Identity Services (CIS) module.
  * This struct defines the properties of a notification subscription, including the tenant ID, subscription ID, source system, callback URL, and the last updated timestamp.
  * The `toJson()` method is provided to serialize the notification subscription into a JSON format for API responses or storage purposes.
  * Fields:
  * - `tenantId`: The ID of the tenant this subscription belongs to.
  * - `subscriptionId`: The unique ID of the notification subscription.
  * - `sourceSystem`: The source system that generates the notifications (e.g., "application", "database").
  * - `callbackUrl`: The URL where notifications should be sent when events occur.
  * - `updatedAt`: The timestamp of when the subscription was last updated.
  * Methods:
  * - `toJson()`: Converts the notification subscription to a JSON object for API responses.
  * Example usage:  
  * ```
  *   CISNotificationSubscription subscription;
  *   subscription.tenantId = "tenant123";
  *   subscription.subscriptionId = "sub456";
  *   subscription.sourceSystem = "application";
  *   subscription.callbackUrl = "https://example.com/notify";
  *   subscription.updatedAt = Clock.currTime();
  *   Json subJson = subscription.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the notification subscription into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the JSON payload expected by the API consumers. The `sourceSystem` field helps specify which system is generating the notifications, while the `callbackUrl` field defines where those notifications should be sent. The `updatedAt` field is essential for tracking changes to the subscription and ensuring that the most current version is being applied. The combination of these fields allows for effective management of notification subscriptions within the CIS module, enabling administrators to set up and maintain subscriptions for various source systems and ensure that notifications are delivered to the correct endpoints when relevant events occur. 
 */
struct CISNotificationSubscription {
  string tenantId;
  string subscriptionId;
  string sourceSystem;
  string callbackUrl;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["subscription_id"] = subscriptionId;
    payload["tenant_id"] = tenantId;
    payload["source_system"] = sourceSystem;
    payload["callback_url"] = callbackUrl;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
