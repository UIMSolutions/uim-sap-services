struct ClogLogQuery {
    string tenant;
    string source;
    string contains;
    Nullable!ClogLogLevel level;
    size_t limit = 100;

    static ClogLogQuery fromJson(Json payload, size_t fallbackLimit) {
        ClogLogQuery query;
        query.limit = fallbackLimit;

        if ("tenant" in payload && payload["tenant"].type == Json.Type.string) {
            query.tenant = payload["tenant"].get!string;
        }
        if ("source" in payload && payload["source"].type == Json.Type.string) {
            query.source = payload["source"].get!string;
        }
        if ("contains" in payload && payload["contains"].type == Json.Type.string) {
            query.contains = payload["contains"].get!string;
        }
        if ("level" in payload && payload["level"].type == Json.Type.string) {
            query.level = Nullable!ClogLogLevel(parseLevel(payload["level"].get!string));
        }
        if ("limit" in payload && payload["limit"].type == Json.Type.int_) {
            auto parsed = payload["limit"].get!long;
            if (parsed > 0) {
                query.limit = cast(size_t)parsed;
            }
        }

        return query;
    }
}
