module models.custom_domain;

import std.json;
import std.datetime;
import std.string;

enum DomainStatus {
    ACTIVE,
    INACTIVE,
    PENDING,
    SUSPENDED
}

struct CustomDomain {
    string domainName;
    string owner;
    DomainStatus status;
    DateTime createdAt;
    DateTime updatedAt;
    string[] sslCertificates;

    // Function to convert the CustomDomain struct to JSON
    JsonObject toJson() {
        JsonObject json = JsonObject();
        json["domainName"] = domainName;
        json["owner"] = owner;
        json["status"] = status.toString();
        json["createdAt"] = createdAt.toISOExtString();
        json["updatedAt"] = updatedAt.toISOExtString();
        json["sslCertificates"] = sslCertificates;
        return json;
    }

    // Function to create a CustomDomain from JSON
    static CustomDomain fromJson(JsonObject json) {
        return CustomDomain(
            json["domainName"].get!string,
            json["owner"].get!string,
            DomainStatus.valueOf(json["status"].getString),
            DateTime.fromISOExtString(json["createdAt"].getString),
            DateTime.fromISOExtString(json["updatedAt"].getString),
            json["sslCertificates"].array.map!(x => x.getString).array
        );
    }
}