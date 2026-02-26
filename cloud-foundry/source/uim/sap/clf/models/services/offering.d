module uim.sap.clf.models.services.offering;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

struct CLFServiceOffering {
    string guid;
    string label;
    string provider;
    string description;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["guid"] = guid;
        payload["label"] = label;
        payload["provider"] = provider;
        payload["description"] = description;
        return payload;
    }
}
