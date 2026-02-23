module uim.sap.dqm.models;

import std.datetime : SysTime;
import std.string : strip, toUpper;

import vibe.data.json : Json;

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

struct DQMGeoPoint {
    double latitude;
    double longitude;
    string accuracy = "rooftop";

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["latitude"] = latitude;
        payload["longitude"] = longitude;
        payload["accuracy"] = accuracy;
        return payload;
    }
}

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

DQMAddress addressFromJson(Json request, string defaultCountry) {
    DQMAddress address;
    address.country = defaultCountry;

    if ("line1" in request && request["line1"].type == Json.Type.string) address.line1 = request["line1"].get!string;
    if ("line2" in request && request["line2"].type == Json.Type.string) address.line2 = request["line2"].get!string;
    if ("city" in request && request["city"].type == Json.Type.string) address.city = request["city"].get!string;
    if ("postal_code" in request && request["postal_code"].type == Json.Type.string) address.postalCode = request["postal_code"].get!string;
    if ("region" in request && request["region"].type == Json.Type.string) address.region = request["region"].get!string;
    if ("country" in request && request["country"].type == Json.Type.string) address.country = request["country"].get!string;

    return address;
}

DQMAddress standardizedAddress(DQMAddress address, bool uppercaseCity, bool keepLine2) {
    auto output = address;
    output.line1 = output.line1.strip;
    output.line2 = keepLine2 ? output.line2.strip : "";
    output.city = uppercaseCity ? toUpper(output.city.strip) : output.city.strip;
    output.postalCode = toUpper(output.postalCode.strip);
    output.region = output.region.strip;
    output.country = toUpper(output.country.strip);
    return output;
}
