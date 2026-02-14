module rfc.examples.basic_usage;

/**
 * Basic usage example for SAP RFC adapter
 */
import uim.sap.rfc;
import vibe.data.json : Json;
import std.stdio : writeln;

void main() {
    auto cfg = SAPRFCConfig.createBasic(
        "https://my.sap.system",
        "SAPUSER",
        "SAPPASSWORD",
        "100"
    );

    cfg.endpointPath = "/sap/bc/rfc";

    auto client = new SAPRFCClient(cfg);

    if (!client.testConnection()) {
        writeln("Could not connect to SAP RFC adapter endpoint");
        return;
    }

    Json params = Json.emptyObject;
    params["REQUTEXT"] = "Hello from uim-sap-rfc";

    try {
        auto result = client.invoke("STFC_CONNECTION", params);
        writeln("RFC call successful with status: ", result.statusCode);
        writeln("Response payload: ", result.data.toString());
    } catch (SAPRFCException e) {
        writeln("RFC call failed: ", e.msg);
    }
}
