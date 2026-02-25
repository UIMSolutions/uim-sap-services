module uim.sap.idoc.models.controlrecord;

import uim.sap.idoc;
@safe:

struct IDocControlRecord {
    string messageType;
    string idocType;
    string senderPort;
    string senderPartner;
    string receiverPort;
    string receiverPartner;

    Json toJson() const {
        Json data = Json.emptyObject;
        if (messageType.length > 0) data["messageType"] = Json(messageType);
        if (idocType.length > 0) data["idocType"] = Json(idocType);
        if (senderPort.length > 0) data["senderPort"] = Json(senderPort);
        if (senderPartner.length > 0) data["senderPartner"] = Json(senderPartner);
        if (receiverPort.length > 0) data["receiverPort"] = Json(receiverPort);
        if (receiverPartner.length > 0) data["receiverPartner"] = Json(receiverPartner);
        return data;
    }
}