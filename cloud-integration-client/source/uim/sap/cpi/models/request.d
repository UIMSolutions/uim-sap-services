module uim.sap.cpi.models.request;

struct CPIRequest {
    string path;
    string[string] query;
    Json payload = Json.emptyObject;
}