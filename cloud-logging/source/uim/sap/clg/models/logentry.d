/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.models.logentry;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

/** 
  * Represents a log entry in the CLG system.
  * This struct is used to encapsulate all relevant information about a log entry, including its ID, timestamp, tenant, source, log level, message, and any additional attributes.
  * It provides methods for converting to and from JSON format, which is useful for API interactions and storage.
  *
  * The `fromJson` method allows creating a `CLGLogEntry` instance from a JSON payload, while the `toJson` method converts an instance back to JSON format.
  */
class CLGLogEntry : SAPEntity {
 mixin(SAPEntityTemplate!CLGLogEntry);

override bool initialize(Json[string] initData = null) {
	if (!super.initialize(initData)) {
return false;
}
        if ("tenant" in initData && initData["tenant"].isString) {
            tenant = initData["tenant"].getString;
        }
        if ("source" in initData && initData["source"].isString) {
            source = initData["source"].getString;
        }
        if ("level" in initData && initData["level"].isString) {
            level = initData(payload["level"].get!string);
        }
        if ("message" in initData && initData["message"].isString) {
            message = initData["message"].getString;
        }
        if ("attributes" in initData) {
            attributes = initData["attributes"];
        }

return true;
}
    UUID id;
    SysTime timestamp;
    string tenant;
    string source;
    CLGLogLevel level = CLGLogLevel.INFO;
    string message;
    Json attributes = Json.emptyObject;


    override Json toJson()  {
        return super.toJson()
        .set("id", id)
        .set("timestamp", timestamp.toISOExtString())
        .set("tenant", tenant)
        .set("source", source)
        .set("level", formatLevel(level))
        .set("message", message)
        .set("attributes", attributes);
    }

    static CLGLogEntry opCall(Json payload) {
        CLGLogEntry entry = new CLGLogEntry(payload);
        entry.Id = randomUUID();
        entry.timestamp = Clock.currTime();

        return entry;
    }
}
