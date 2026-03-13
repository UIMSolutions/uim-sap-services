module uim.sap.s4hana.models.request;
import uim.sap.s4hana;

mixin(ShowModule!());

@safe:
struct S4HANARequest {
    string servicePath;
    string entityPath;
    string[string] query;
    Json payload = Json.emptyObject;

    string requestPath() const {
        auto service = servicePath;
        if (service.length > 0 && service[$ - 1] == '/') {
            service = service[0 .. $ - 1];
        }

        auto entity = entityPath;
        if (entity.length > 0 && entity[0] == '/') {
            entity = entity[1 .. $];
        }

        if (entity.length == 0) {
            return service;
        }

        return service ~ "/" ~ entity;
    }
}