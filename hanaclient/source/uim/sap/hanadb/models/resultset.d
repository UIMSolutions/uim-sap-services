module uim.sap.hanadb.models.resultset;

struct HanaDBResultSet {
    string[] columns;
    Json[] rows;
    long rowCount;
}