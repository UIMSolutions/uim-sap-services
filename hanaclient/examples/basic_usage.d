module hanaclint.examples.basic_usage;

/**
 * Basic usage example for SAP HANA DB client
 */
import uim.sap.hanadb;
import vibe.data.json : Json;
import std.stdio : writeln;

void main() {
    auto cfg = HanaDBConfig.createBasic(
        "https://my-hana.example.com",
        "MY_SCHEMA",
        "DBUSER",
        "DBPASSWORD"
    );

    cfg.endpointPath = "/sql";

    auto client = new HanaDBClient(cfg);

    try {
        client.connect();
        writeln("Connected: ", client.isConnected);

        auto check = client.query("SELECT 1 AS OK FROM DUMMY");
        writeln("Health query rows: ", check.resultSet.rowCount);

        Json params = Json.emptyArray;
        params ~= Json("A");

        auto data = client.query("SELECT * FROM PRODUCTS WHERE CATEGORY = ?", params);
        writeln("Data rows: ", data.resultSet.rowCount);

        client.beginTransaction();
        client.execute("UPDATE PRODUCTS SET LAST_CHECK = CURRENT_UTCTIMESTAMP WHERE CATEGORY = 'A'");
        client.commit();
    } catch (HanaDBException e) {
        writeln("HANA DB error: ", e.msg);
        try {
            client.rollback();
        } catch (Exception) {
        }
    } finally {
        client.disconnect();
    }
}
