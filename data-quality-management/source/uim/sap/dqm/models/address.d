module uim.sap.dqm.models.address;

struct DQMAddress {
    string line1;
    string line2;
    string city;
    string postalCode;
    string region;
    string country;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["line1"] = line1;
        payload["line2"] = line2;
        payload["city"] = city;
        payload["postal_code"] = postalCode;
        payload["region"] = region;
        payload["country"] = country;
        return payload;
    }
}