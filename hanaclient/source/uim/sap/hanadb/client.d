/**
 * HANA Database client
 */
module uim.sap.hanadb.client;

import std.base64 : Base64;
import std.datetime : Clock;
import std.string : format;

import vibe.data.json : Json;
import vibe.http.client : requestHTTP, HTTPClientRequest;
import vibe.http.common : HTTPMethod;

import uim.sap.hanadb.config;
import uim.sap.hanadb.exceptions;
import uim.sap.hanadb.models;

class HanaDBClient {
    private HanaDBConfig _config;
    private bool _connected;

    this(HanaDBConfig config) {
        config.validate();
        _config = config;
    }

    @property const(HanaDBConfig) config() const {
        return _config;
    }

    @property bool isConnected() const pure nothrow @safe @nogc {
        return _connected;
    }

    void connect() {
        auto response = query("SELECT 1 AS HEALTH_CHECK FROM DUMMY");
        if (!response.success) {
            throw new HanaDBConnectionException("Failed to establish HANA DB connection");
        }
        _connected = true;
    }

    void disconnect() {
        _connected = false;
    }

    bool testConnection() {
        try {
            auto response = query("SELECT CURRENT_UTCTIMESTAMP AS TS FROM DUMMY");
            return response.success;
        } catch (Exception) {
            return false;
        }
    }

    HDBResponse query(string sql, Json parameters = Json.emptyArray) {
        if (sql.length == 0) {
            throw new HanaDBQueryException("SQL statement cannot be empty");
        }

        HanaDBQueryRequest request;
        request.statement = sql;
        request.parameters = parameters;

        return executeRequest(request);
    }

    HDBResponse execute(string sql, Json parameters = Json.emptyArray) {
        return query(sql, parameters);
    }

    HDBResponse[] executeBatch(string[] sqlStatements) {
        HDBResponse[] responses;
        foreach (statement; sqlStatements) {
            responses ~= query(statement);
        }
        return responses;
    }

    void beginTransaction() {
        query("BEGIN");
    }

    void commit() {
        query("COMMIT");
    }

    void rollback() {
        query("ROLLBACK");
    }

    private HDBResponse executeRequest(HanaDBQueryRequest request) {
        uint attempts = 0;

        while (attempts <= _config.maxRetries) {
            try {
                HDBResponse response;
                response.timestamp = Clock.currTime();

                requestHTTP(_config.sqlUrl(),
                    (scope req) {
                        req.method = HTTPMethod.POST;
                        req.headers["Content-Type"] = "application/json";
                        req.headers["Accept"] = "application/json";
                        req.headers["X-SAP-Database"] = _config.database;

                        applyAuth(req);

                        foreach (key, value; _config.customHeaders) {
                            req.headers[key] = value;
                        }

                        req.writeJsonBody(request.toJson());
                    },
                    (scope res) {
                        response.statusCode = res.statusCode;
                        response.success = res.statusCode >= 200 && res.statusCode < 300;

                        try {
                            response.raw = res.readJson();
                        } catch (Exception) {
                            response.raw = Json.emptyObject;
                        }

                        if (response.success) {
                            response.resultSet = parseResultSet(response.raw);
                        } else {
                            response.errorMessage = extractErrorMessage(response.raw, res.statusCode);
                        }
                    }
                );

                if (!response.success) {
                    throw new HanaDBQueryException(response.errorMessage, response.statusCode);
                }

                return response;
            } catch (HanaDBQueryException e) {
                throw e;
            } catch (Exception e) {
                attempts++;
                if (attempts > _config.maxRetries) {
                    throw new HanaDBConnectionException(
                        format("HANA request failed after %d retries: %s", attempts, e.msg)
                    );
                }
            }
        }

        throw new HanaDBConnectionException("HANA request failed with unknown error");
    }

    private HanaDBResultSet parseResultSet(Json payload) {
        HanaDBResultSet resultSet;

        if ("columns" in payload && payload["columns"].type == Json.Type.array) {
            foreach (col; payload["columns"]) {
                if (col.type == Json.Type.string) {
                    resultSet.columns ~= col.get!string;
                }
            }
        }

        if ("rows" in payload && payload["rows"].type == Json.Type.array) {
            foreach (row; payload["rows"]) {
                resultSet.rows ~= row;
            }
            resultSet.rowCount = cast(long)resultSet.rows.length;
        } else if ("d" in payload && payload["d"].type == Json.Type.object && "results" in payload["d"]) {
            auto results = payload["d"]["results"];
            if (results.type == Json.Type.array) {
                foreach (row; results) {
                    resultSet.rows ~= row;
                }
                resultSet.rowCount = cast(long)resultSet.rows.length;
            }
        }

        return resultSet;
    }

    private string extractErrorMessage(Json payload, int statusCode) {
        if ("error" in payload) {
            auto err = payload["error"];

            if (err.type == Json.Type.object) {
                if ("message" in err) {
                    auto messageNode = err["message"];
                    if (messageNode.type == Json.Type.string) {
                        return messageNode.get!string;
                    }

                    if (messageNode.type == Json.Type.object && "value" in messageNode) {
                        return messageNode["value"].get!string;
                    }
                }
            }
        }

        return format("HANA request failed with status code %d", statusCode);
    }

    private void applyAuth(HTTPClientRequest req) {
        final switch (_config.authType) {
            case HanaDBAuthType.Basic:
                auto creds = _config.username ~ ":" ~ _config.password;
                auto token = Base64.encode(cast(const(ubyte)[])creds).idup;
                req.headers["Authorization"] = "Basic " ~ token;
                break;
            case HanaDBAuthType.Bearer:
                req.headers["Authorization"] = "Bearer " ~ _config.bearerToken;
                break;
        }
    }
}
