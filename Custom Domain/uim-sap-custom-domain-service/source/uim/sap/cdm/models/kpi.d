module models.kpi;

import std.datetime;
import std.json;

struct Kpi {
    string name;
    double value;
    DateTime timestamp;
    string description;

    // Method to convert the KPI to JSON format
    JsonValue toJson() {
        JsonValue json = JsonValue();
        json["name"] = name;
        json["value"] = value;
        json["timestamp"] = timestamp.toISOExtString();
        json["description"] = description;
        return json;
    }

    // Method to create a KPI from JSON format
    static Kpi fromJson(JsonValue json) {
        return Kpi(
            json["name"].str,
            json["value"].toDouble(),
            DateTime.fromISOExtString(json["timestamp"].str),
            json["description"].str
        );
    }
}