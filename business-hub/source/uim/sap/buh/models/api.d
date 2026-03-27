/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.buh.models.api;

import uim.sap.buh;

mixin(ShowModule!());

@safe:

/**
  * Represents an API in the Business Hub.
  * This struct is used for both API definitions and instances, as the Business Hub does not differentiate between the two.
  *
  * The `id` field serves as a unique identifier for the API, while `name`, `provider`, and `version` provide descriptive information.
  * The `visibility` field indicates whether the API is public or private, and `summary` offers a brief description of the API's functionality.
  * The `tags` array allows for categorization and easier searching of APIs based on keywords.
  * The `createdAt` field records the timestamp of when the API was created, which can be useful for tracking and auditing purposes.
  */
class BUHApi : SAPObject {
  mixin(SAPObjectTemplate!BUHApi);

  UUID id;
  string name;
  string provider;
  string apiVersion;
  string visibility = "public";
  string summary;
  string[] tags;

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("name" in initData && initData["name"].isString) {
      api.name = initData["name"].getString;
    }
    if ("provider" in initData && initData["provider"].isString) {
      api.provider = initData["provider"].getString;
    }
    if ("version" in initData && initData["version"].isString) {
      api.apiVersion = initData["version"].getString;
    }
    if ("visibility" in initData && initData["visibility"].isString) {
      api.visibility = initData["visibility"].getString;
    }
    if ("summary" in initData && initData["summary"].isString) {
      api.summary = initData["summary"].getString;
    }

    if ("tags" in initData && initData["tags"].isArray) {
      foreach (entry; initData["tags"]) {
        if (entry.isString) {
          api.tags ~= entry.getString;
        }
      }
    }

    return true;
  }

  override Json toJson() {
    Json jsonTags = tags.map!(tag => Json(tag)).array.toJson;

    return super.toJson
      .set("id", id)
      .set("name", name)
      .set("provider", provider)
      .set("version", apiVersion)
      .set("visibility", visibility)
      .set("summary", summary)
      .set("tags", jsonTags)
      .set("created_at", createdAt.toISOExtString());
  }
}

BUHApi apiFromJson(Json data) {
  BUHApi api = new BUHApi(data);
  api.id = randomUUID();
  api.createdAt = Clock.currTime();

  return api;
}
