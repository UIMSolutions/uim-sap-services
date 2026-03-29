/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.models.logquery;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

/**
  * Represents a log query in the CLG system.
  * This struct is used to encapsulate all relevant information about a log query, including tenant, source, search string, log level, and limit.
  * It provides a method for creating an instance from a JSON payload, which is useful for API interactions.
  *
  * The `fromJson` method allows creating a `CLGLogQuery` instance from a JSON payload, using a fallback limit if the limit is not specified or invalid.
  *
  * Fields:
  * - `tenant`: The tenant for which the logs are being queried.
  * - `source`: The source of the logs to query.
  * - `contains`: A search string to filter log messages that contain this substring.
  * - `level`: An optional log level to filter the logs.
  * - `limit`: The maximum number of log entries to return, with a default value of 100.
  */
class CLGLogQuery : SAPEntity {
mixin(SAPEntityTemplate!CLGLogQuery);

override bool initialize(Json[string] initData = null) {
if (!super.initialize(initData)) {
return false;
}

        if ("tenant" in payload && payload["tenant"].isString) {
            query.tenant = payload["tenant"].getString;
        }
        if ("source" in payload && payload["source"].isString) {
            query.source = payload["source"].getString;
        }
        if ("contains" in payload && payload["contains"].isString) {
            query.contains = payload["contains"].getString;
        }
        if ("level" in payload && payload["level"].isString) {
            query.level = new CLGLogLevel(parseLevel(payload["level"].get!string));
        }
        if ("limit" in payload && payload["limit"].isInteger) {
            auto parsed = payload["limit"].get!long;
            if (parsed > 0) {
                query.limit = cast(size_t)parsed;
            }
        }

return true;
}
    string tenant;
    string source;
    string contains;
    Nullable!CLGLogLevel level;
    size_t limit = 100;

    static CLGLogQuery opCall(Json payload, size_t fallbackLimit) {
        CLGLogQuery query = new CLGLogQuery(payload);
        query.limit = fallbackLimit;

        return query;
    }
}
