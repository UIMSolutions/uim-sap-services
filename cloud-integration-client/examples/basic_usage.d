module cpi.examples.basic_usage;

/**
 * Basic usage example for CPI client
 */
import uim.sap.cpi;
import vibe.data.json : Json;
import std.stdio : writeln;
version (unittest) {
} else {
  void main() {
  auto config = CPIConfig.createBasic(
    "https://mytenant.it-cpi020.cfapps.eu10.hana.ondemand.com",
    "CPI_USER",
    "CPI_PASSWORD"
  );

  auto client = new CPIClient(config);

  try {
    if (!client.testConnection()) {
      writeln("CPI connection test failed");
      return;
    }

    auto artifacts = client.getIntegrationArtifacts(5, 0);
    writeln("Artifacts request status: ", artifacts.statusCode);

    auto logs = client.getMessageProcessingLogs(5, 0, "FAILED");
    writeln("MPL request status: ", logs.statusCode);

    Json payload = Json.emptyObject
      .set("event", Json("ping"));

    auto trigger = client.triggerIntegrationFlow("/http/DEMO_IFLOW", payload);
    writeln("Trigger status: ", trigger.statusCode);
  } catch (CPIException e) {
    writeln("CPI error: ", e.msg);
  }
}
