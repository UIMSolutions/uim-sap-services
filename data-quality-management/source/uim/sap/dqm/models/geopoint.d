module uim.sap.dqm.models.geopoint;

struct DQMGeoPoint {
    double latitude;
    double longitude;
    string accuracy = "rooftop";

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["latitude"] = latitude;
        payload["longitude"] = longitude;
        payload["accuracy"] = accuracy;
        return payload;
    }
}