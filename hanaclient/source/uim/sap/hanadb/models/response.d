module uim.sap.hanadb.models.response;

struct HDBResponse {
    bool success;
    int statusCode;
    string errorMessage;
    Json raw = Json.emptyObject;
    HanaDBResultSet resultSet;
    SysTime timestamp;

    bool isSuccess() const pure nothrow @safe @nogc {
        return success;
    }
}