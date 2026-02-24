module models.certificate;

import std.datetime;
import std.json;

// Represents a TLS/SSL certificate
struct Certificate {
    string id; // Unique identifier for the certificate
    string domain; // The domain associated with the certificate
    string certificateData; // The actual certificate data
    string privateKey; // The private key associated with the certificate
    DateTime expirationDate; // Expiration date of the certificate
    bool isActive; // Indicates if the certificate is currently active

    // Function to check if the certificate is expired
    bool isExpired() {
        return expirationDate < DateTime.now();
    }

    // Function to serialize the certificate to JSON
    JsonValue toJson() {
        return JsonValue([
            "id": id,
            "domain": domain,
            "expirationDate": expirationDate.toISOExtString(),
            "isActive": isActive
        ]);
    }

    // Function to deserialize JSON to a Certificate object
    static Certificate fromJson(JsonValue json) {
        return Certificate(
            json["id"].str,
            json["domain"].str,
            json["certificateData"].str,
            json["privateKey"].str,
            DateTime.fromISOExtString(json["expirationDate"].str),
            json["isActive"].bool
        );
    }
}