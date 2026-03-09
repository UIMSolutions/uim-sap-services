module uim.sap.cpi.models.request;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

struct CPIRequest {
    string path;
    string[string] query;
    Json payload = Json.emptyObject;
}