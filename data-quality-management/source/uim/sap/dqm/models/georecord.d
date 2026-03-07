module uim.sap.dqm.models.georecord;

struct DQMGeoRecord {
    DQMAddress address;
    DQMGeoPoint point;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["address"] = address.toJson();
        payload["point"] = point.toJson();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
