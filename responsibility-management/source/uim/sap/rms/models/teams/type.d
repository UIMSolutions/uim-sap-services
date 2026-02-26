module uim.sap.rms.models.models.teams.type;

import uim.sap.rms;
@safe:

struct TeamTypeDef {
    string code;
    string name;
    string description;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["code"] = code;
        payload["name"] = name;
        payload["description"] = description;
        return payload;
    }
}