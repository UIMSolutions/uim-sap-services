/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.models.contentitem;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGContentItem : SAPTenantObject {
  mixin(SAPObjectTemplate!CMGContentItem);

    UUID itemId;
    string contentType;
    string title;
    string description;
    string source;
    string sourceRef;
    string[] tags;
    Json config;

    override Json toJson()  {
        Json tagValues = tags.map!(tag => tag).array.toJson;

        return super.toJson
        .set("item_id", itemId)
        .set("content_type", contentType)
        .set("title", title)
        .set("description", description)
        .set("source", source)
        .set("source_ref", sourceRef)
        .set("tags", tagValues)
        .set("config", config);
    }
}