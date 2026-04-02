/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.server.server;

import uim.sap.cap.cds;
import uim.sap.cap.events.types;
import uim.sap.cap.srv.application;
import uim.sap.service;

import std.algorithm : canFind;
import std.conv : to;
import std.string : indexOf, join, split, strip, toLower;

/// CAP Server that auto-exposes ApplicationService entities as REST endpoints.
///
/// Route pattern:
///   GET    {basePath}/{Entity}         → READ collection
///   GET    {basePath}/{Entity}/{id}    → READ single
///   POST   {basePath}/{Entity}         → CREATE
///   PUT    {basePath}/{Entity}/{id}    → UPDATE
///   PATCH  {basePath}/{Entity}/{id}    → UPDATE
///   DELETE {basePath}/{Entity}/{id}    → DELETE
///   POST   {basePath}/{action}         → Custom action
///
/// OData-like query parameters: $select, $top, $skip, $orderby, $count, $filter
class CAPServer : SAPServer {
    mixin(SAPServerTemplate!CAPServer);

    private ApplicationService _appService;

    this(ApplicationService service, string host = "0.0.0.0", ushort port = 4004,
         string basePath = "/odata/v4") {
        _appService = service;
        _host = host;
        _port = port;
        _basePath = basePath;
    }

    override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            // Apply custom headers
            foreach (key, value; _customHeaders)
                res.headers[key] = value;

            // Parse the sub-path (after basePath)
            auto fullPath = req.requestURI;
            auto qIdx = fullPath.indexOf('?');
            auto pathOnly = qIdx >= 0 ? fullPath[0 .. qIdx] : fullPath;

            if (!pathOnly.startsWith(_basePath)) {
                // Check built-in platform endpoints
                if (pathOnly == "/health" || pathOnly == _basePath ~ "/health") {
                    writeJsonResponse(res, 200, _appService.health());
                    return;
                }
                if (pathOnly == "/ready" || pathOnly == _basePath ~ "/ready") {
                    writeJsonResponse(res, 200, _appService.ready());
                    return;
                }
                // Serve $metadata
                if (pathOnly == _basePath ~ "/$metadata" || pathOnly == _basePath ~ "/metadata") {
                    writeJsonResponse(res, 200, buildMetadata());
                    return;
                }
                respondError(res, "Not found", 404);
                return;
            }

            auto subPath = pathOnly[_basePath.length .. $];
            if (subPath.length > 0 && subPath[0] == '/')
                subPath = subPath[1 .. $];

            auto segments = normalizedSegments(subPath);

            if (segments.length == 0) {
                // Service root — return entity list
                writeJsonResponse(res, 200, buildServiceDocument());
                return;
            }

            // First segment: entity name or action name
            auto entityOrAction = segments[0];

            // Check platform endpoints
            if (entityOrAction == "health") {
                writeJsonResponse(res, 200, _appService.health());
                return;
            }
            if (entityOrAction == "ready") {
                writeJsonResponse(res, 200, _appService.ready());
                return;
            }
            if (entityOrAction == "$metadata" || entityOrAction == "metadata") {
                writeJsonResponse(res, 200, buildMetadata());
                return;
            }

            auto model = _appService.model();

            // Check if it's an entity
            if (model !is null && model.hasEntity(entityOrAction)) {
                auto entityName = entityOrAction;
                string entityId = segments.length > 1 ? segments[1] : "";

                // Collect OData query parameters
                string[string] params;
                params["$select"] = getQueryParam(req, "$select");
                params["$top"] = getQueryParam(req, "$top");
                params["$skip"] = getQueryParam(req, "$skip");
                params["$orderby"] = getQueryParam(req, "$orderby");
                params["$count"] = getQueryParam(req, "$count");
                params["$filter"] = getQueryParam(req, "$filter");
                if (entityId.length > 0)
                    params["id"] = entityId;

                // Authenticate
                string user = "";
                if (_requireAuthToken) {
                    if (!validateAuth(req, null)) {
                        respondError(res, "Unauthorized", 401);
                        return;
                    }
                }

                auto method = req.method.to!string;

                if (method == "GET") {
                    auto result = _appService.dispatch(CrudEvent.READ, entityName,
                        Json.emptyObject, params, user);
                    writeJsonResponse(res, 200, result);

                } else if (method == "POST") {
                    // Check for bound action (3rd segment)
                    if (segments.length > 2) {
                        auto actionName = segments[2];
                        auto body = parseBody(req);
                        params["id"] = entityId;
                        auto result = _appService.dispatchAction(actionName, body, params, user);
                        writeJsonResponse(res, 200, result);
                    } else {
                        auto body = parseBody(req);
                        auto result = _appService.dispatch(CrudEvent.CREATE, entityName,
                            body, params, user);
                        writeJsonResponse(res, 201, result);
                    }

                } else if (method == "PUT" || method == "PATCH") {
                    if (entityId.length == 0) {
                        respondError(res, "Entity ID required for update", 400);
                        return;
                    }
                    auto body = parseBody(req);
                    auto result = _appService.dispatch(CrudEvent.UPDATE, entityName,
                        body, params, user);
                    writeJsonResponse(res, 200, result);

                } else if (method == "DELETE") {
                    if (entityId.length == 0) {
                        respondError(res, "Entity ID required for delete", 400);
                        return;
                    }
                    auto result = _appService.dispatch(CrudEvent.DELETE, entityName,
                        Json.emptyObject, params, user);
                    writeJsonResponse(res, 204, result);

                } else {
                    respondError(res, "Method not allowed", 405);
                }
                return;
            }

            // Not an entity — try as a custom action
            if (req.method.to!string == "POST") {
                try {
                    auto body = parseBody(req);
                    auto result = _appService.dispatchAction(entityOrAction, body);
                    writeJsonResponse(res, 200, result);
                    return;
                } catch (SAPValidationException e) {
                    respondError(res, e.msg, 422);
                    return;
                }
            }

            respondError(res, "Not found: " ~ entityOrAction, 404);

        } catch (SAPAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (SAPValidationException e) {
            respondError(res, e.msg, 422);
        } catch (SAPConfigurationException e) {
            respondError(res, e.msg, 500);
        } catch (SAPException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, "Internal server error", 500);
        }
    }

    /// Build OData-like service document listing available entity sets.
    private Json buildServiceDocument() {
        auto doc = Json.emptyObject;
        auto entitySets = Json.emptyArray;
        auto model = _appService.model();
        if (model !is null) {
            foreach (name; model.entityNames()) {
                auto entry = Json.emptyObject;
                entry["name"] = Json(name);
                entry["url"] = Json(name);
                entitySets ~= entry;
            }
        }
        doc["value"] = entitySets;
        return doc;
    }

    /// Build a simple $metadata response describing entities and their fields.
    private Json buildMetadata() {
        auto meta = Json.emptyObject;
        auto model = _appService.model();
        if (model is null) return meta;

        meta["$Version"] = Json("4.0");
        auto schemas = Json.emptyObject;

        foreach (name; model.entityNames()) {
            auto entDef = model.getEntity(name);
            if (entDef is null) continue;

            auto props = Json.emptyObject;
            foreach (f; entDef.fields) {
                auto prop = Json.emptyObject;
                prop["$Type"] = Json(cdsTypeToEdm(f.type_));
                if (f.length > 0)
                    prop["$MaxLength"] = Json(f.length);
                if (f.isKey)
                    prop["$Key"] = Json(true);
                if (f.isNotNull)
                    prop["$Nullable"] = Json(false);
                props[f.name] = prop;
            }
            schemas[name] = props;
        }

        meta["$EntityTypes"] = schemas;
        return meta;
    }

    /// Map CDS types to OData EDM type names.
    private static string cdsTypeToEdm(CdsType t) {
        import uim.sap.cap.cds.types;
        final switch (t) {
            case CdsType.UUID:          return "Edm.Guid";
            case CdsType.String:        return "Edm.String";
            case CdsType.Integer:       return "Edm.Int32";
            case CdsType.Integer64:     return "Edm.Int64";
            case CdsType.Decimal:       return "Edm.Decimal";
            case CdsType.Double:        return "Edm.Double";
            case CdsType.Boolean:       return "Edm.Boolean";
            case CdsType.Date:          return "Edm.Date";
            case CdsType.Time:          return "Edm.TimeOfDay";
            case CdsType.DateTime:      return "Edm.DateTimeOffset";
            case CdsType.Timestamp:     return "Edm.DateTimeOffset";
            case CdsType.Binary:        return "Edm.Binary";
            case CdsType.LargeBinary:   return "Edm.Binary";
            case CdsType.LargeString:   return "Edm.String";
            case CdsType.Association:   return "Edm.NavigationProperty";
            case CdsType.Composition:   return "Edm.NavigationProperty";
        }
    }

    /// Write a JSON response with the given status code.
    private static void writeJsonResponse(HTTPServerResponse res, int status, Json data) {
        res.writeBody(data.toString(), cast(int) status, "application/json");
    }

    /// Safely extract a query parameter from the request.
    private static string getQueryParam(HTTPServerRequest req, string key) {
        auto params = req.queryString;
        // Simple query string parser
        foreach (part; params.split("&")) {
            auto eqIdx = part.indexOf('=');
            if (eqIdx >= 0) {
                auto k = part[0 .. eqIdx];
                if (k == key)
                    return part[eqIdx + 1 .. $];
            }
        }
        return "";
    }

    /// Parse a path string and a check if it starts with a prefix.
    private static bool startsWith(string s, string prefix) {
        return s.length >= prefix.length && s[0 .. prefix.length] == prefix;
    }
}
