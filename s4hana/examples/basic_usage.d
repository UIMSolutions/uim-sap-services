module s4hana.examples.basic_usage;

/**
 * Basic usage example for S/4HANA client
 */
import uim.sap.s4hana;
import vibe.data.json : Json;
import std.stdio : writeln;
version (unittest) {
} else {
  void main() {
    auto config = S4HANAConfig.createBasic(
        "https://my-s4hana.example.com",
        "SAPUSER",
        "SAPPASSWORD",
        "100"
    );

    auto client = new S4HANAClient(config);

    try {
        if (!client.testConnection()) {
            writeln("Connection test failed");
            return;
        }

        auto bpList = client.getBusinessPartners(5, 0);
        writeln("Business Partner list request status: ", bpList.statusCode);

        Json payload = Json.emptyObject;
        payload["BusinessPartnerCategory"] = Json("2");
        payload["OrganizationBPName1"] = Json("Demo Partner");

        auto created = client.postOData("API_BUSINESS_PARTNER", "A_BusinessPartner", payload);
        writeln("Create request status: ", created.statusCode);
    } catch (S4HANAException e) {
        writeln("S/4HANA error: ", e.msg);
    }
}
