module uim.sap.mob.models.notification;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Individual push notification
struct MOBNotification {
  string id;
  string appId;
  string title;
  string body_;
  MOBPushPriority priority = MOBPushPriority.NORMAL;
  string[] targetUsers; // empty = broadcast to all users
  string category; // notification category/channel
  Json customData; // app-specific payload
  size_t deliveredCount;
  size_t failedCount;
  SysTime sentAt;

  override Json toJson() {
    Json targets = Json.emptyArray;
    foreach (t; targetUsers)
      targets.appendArrayElement(Json(t));

    Json j = super.toJson
      .set("id", id)
      .set("app_id", appId)
      .set("title", title)
      .set("body", body_)
      .set("priority", cast(string)priority)
      .set("target_users", targets)
      .set("category", category)
      .set("delivered_count", cast(long)deliveredCount)
      .set("failed_count", cast(long)failedCount)
      .set("sent_at", sentAt.toISOExtString());

    if (!customData.isUndefined && !customData.isNull)
      j.set("custom_data", customData);

    return j;
  }
}

MOBNotification notificationFromJson(string appId, Json req) {
  MOBNotification n;
  n.id = randomUUID();
  n.appId = appId;
  n.sentAt = Clock.currTime();

  if ("title" in req && req["title"].isString)
    n.title = req["title"].get!string;
  if ("body" in req && req["body"].isString)
    n.body_ = req["body"].get!string;
  if ("priority" in req && req["priority"].isString)
    n.priority = parsePushPriority(req["priority"].get!string);
  if ("target_users" in req && req["target_users"].isArray) {
    foreach (v; req["target_users"])
      if (v.isString)
        n.targetUsers ~= v.get!string;
  }
  if ("category" in req && req["category"].isString)
    n.category = req["category"].get!string;
  if ("custom_data" in req)
    n.customData = req["custom_data"];
  return n;
}
