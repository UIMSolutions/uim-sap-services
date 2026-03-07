module uim.sap.documentmanagement.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.documentmanagement.exceptions;
import uim.sap.documentmanagement.service;

/**
 * HTTP server for the Document Management Service.
 *
 * Routes all incoming requests to the appropriate DMAService
 * method based on URL path segments and HTTP method.
 */
class DMAServer {
    private DMAService _service;

    this(DMAService service) {
        _service = service;
    }

    void run() {
        auto settings = new HTTPServerSettings;
        settings.port = _service.config.port;
        settings.bindAddresses = [_service.config.host];
        listenHTTP(settings, &handleRequest);
        runApplication();
    }

    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _service.config.customHeaders) {
            res.headers[key] = value;
        }

        auto basePath = _service.config.basePath;
        auto path = req.path;

        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0)
            subPath = "/";

        // ---------------------------------------------------------------
        // Platform endpoints (no auth required)
        // ---------------------------------------------------------------
        if (subPath == "/health" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.health(), 200);
            return;
        }
        if (subPath == "/ready" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.ready(), 200);
            return;
        }

        // All other endpoints require auth
        try {
            validateAuth(req);
            auto segments = normalizedSegments(subPath);

            if (segments.length == 0) {
                respondError(res, "Not found", 404);
                return;
            }

            // v1 API namespace
            if (segments[0] == "v1") {
                if (routeV1(segments[1 .. $], req, res))
                    return;
            }

            respondError(res, "Not found", 404);

        } catch (DMAAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (DMANotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (DMAConflictException e) {
            respondError(res, e.msg, 409);
        } catch (DMAPayloadTooLargeException e) {
            respondError(res, e.msg, 413);
        } catch (DMAValidationException e) {
            respondError(res, e.msg, 422);
        } catch (DMAException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    // -------------------------------------------------------------------
    // V1 route dispatcher
    // -------------------------------------------------------------------

    private bool routeV1(string[] seg, HTTPServerRequest req, HTTPServerResponse res) {
        // /v1/repositories
        if (seg.length >= 1 && seg[0] == "repositories") {
            return routeRepositories(seg[1 .. $], req, res);
        }

        // /v1/documents/{id}/...
        if (seg.length >= 2 && seg[0] == "documents") {
            return routeDocument(seg[1], seg[2 .. $], req, res);
        }

        // /v1/folders/{id}/...
        if (seg.length >= 2 && seg[0] == "folders") {
            return routeFolder(seg[1], seg[2 .. $], req, res);
        }

        // /v1/encryption/status
        if (seg.length == 2 && seg[0] == "encryption" && seg[1] == "status"
            && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.encryptionStatus(), 200);
            return true;
        }

        return false;
    }

    // -------------------------------------------------------------------
    // /v1/repositories[/...]
    // -------------------------------------------------------------------

    private bool routeRepositories(string[] seg, HTTPServerRequest req, HTTPServerResponse res) {
        // GET /v1/repositories
        if (seg.length == 0 && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listRepositories(), 200);
            return true;
        }
        // POST /v1/repositories
        if (seg.length == 0 && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.connectRepository(req.json), 201);
            return true;
        }

        if (seg.length < 1) return false;
        auto repoId = seg[0];

        // GET /v1/repositories/{id}
        if (seg.length == 1 && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getRepository(repoId), 200);
            return true;
        }
        // DELETE /v1/repositories/{id}
        if (seg.length == 1 && req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.disconnectRepository(repoId), 200);
            return true;
        }

        // /v1/repositories/{id}/folders[/...]
        if (seg.length >= 2 && seg[1] == "folders") {
            return routeRepoFolders(repoId, seg[2 .. $], req, res);
        }

        // /v1/repositories/{id}/documents[/...]
        if (seg.length >= 2 && seg[1] == "documents") {
            return routeRepoDocuments(repoId, seg[2 .. $], req, res);
        }

        // /v1/repositories/{id}/contents?folder_id=...
        if (seg.length == 2 && seg[1] == "contents" && req.method == HTTPMethod.GET) {
            string folderId = "";
            if ("folder_id" in req.query)
                folderId = req.query["folder_id"];
            res.writeJsonBody(_service.listFolderContents(repoId, folderId), 200);
            return true;
        }

        // /v1/repositories/{id}/contents/sorted
        if (seg.length == 3 && seg[1] == "contents" && seg[2] == "sorted"
            && req.method == HTTPMethod.POST) {
            string folderId = "";
            auto body_ = req.json;
            if ("folder_id" in body_ && body_["folder_id"].isString)
                folderId = body_["folder_id"].get!string;
            res.writeJsonBody(_service.listDocumentsSorted(repoId, folderId, body_), 200);
            return true;
        }

        return false;
    }

    // -------------------------------------------------------------------
    // /v1/repositories/{repoId}/folders[/...]
    // -------------------------------------------------------------------

    private bool routeRepoFolders(string repoId, string[] seg,
                                   HTTPServerRequest req, HTTPServerResponse res) {
        // POST /v1/repositories/{id}/folders  (create folder)
        if (seg.length == 0 && req.method == HTTPMethod.POST) {
            string parentId = "";
            if ("parent_folder_id" in req.query)
                parentId = req.query["parent_folder_id"];
            auto body_ = req.json;
            if ("parent_folder_id" in body_ && body_["parent_folder_id"].isString)
                parentId = body_["parent_folder_id"].get!string;
            res.writeJsonBody(_service.createFolder(repoId, parentId, body_), 201);
            return true;
        }
        return false;
    }

    // -------------------------------------------------------------------
    // /v1/repositories/{repoId}/documents[/...]
    // -------------------------------------------------------------------

    private bool routeRepoDocuments(string repoId, string[] seg,
                                     HTTPServerRequest req, HTTPServerResponse res) {
        // POST /v1/repositories/{id}/documents  (create document)
        if (seg.length == 0 && req.method == HTTPMethod.POST) {
            string folderId = "";
            if ("folder_id" in req.query)
                folderId = req.query["folder_id"];
            auto body_ = req.json;
            if ("folder_id" in body_ && body_["folder_id"].isString)
                folderId = body_["folder_id"].get!string;
            res.writeJsonBody(_service.createDocument(repoId, folderId, body_), 201);
            return true;
        }
        return false;
    }

    // -------------------------------------------------------------------
    // /v1/documents/{id}/...
    // -------------------------------------------------------------------

    private bool routeDocument(string docId, string[] seg,
                                HTTPServerRequest req, HTTPServerResponse res) {
        // GET /v1/documents/{id}
        if (seg.length == 0 && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getDocument(docId), 200);
            return true;
        }
        // PUT /v1/documents/{id}
        if (seg.length == 0 && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateDocument(docId, req.json), 200);
            return true;
        }
        // DELETE /v1/documents/{id}
        if (seg.length == 0 && req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteDocument(docId), 200);
            return true;
        }

        // POST /v1/documents/{id}/move
        if (seg.length == 1 && seg[0] == "move" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.moveDocument(docId, req.json), 200);
            return true;
        }
        // POST /v1/documents/{id}/copy
        if (seg.length == 1 && seg[0] == "copy" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.copyDocument(docId, req.json), 200);
            return true;
        }

        // GET /v1/documents/{id}/view
        if (seg.length == 1 && seg[0] == "view" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.viewDocument(docId), 200);
            return true;
        }
        // GET /v1/documents/{id}/download
        if (seg.length == 1 && seg[0] == "download" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.downloadDocument(docId), 200);
            return true;
        }

        // GET /v1/documents/{id}/metadata
        if (seg.length == 1 && seg[0] == "metadata" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getDocumentMetadata(docId), 200);
            return true;
        }
        // PUT /v1/documents/{id}/metadata
        if (seg.length == 1 && seg[0] == "metadata" && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateDocumentMetadata(docId, req.json), 200);
            return true;
        }

        // GET /v1/documents/{id}/versions
        if (seg.length == 1 && seg[0] == "versions" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listVersions(docId), 200);
            return true;
        }
        // POST /v1/documents/{id}/versions
        if (seg.length == 1 && seg[0] == "versions" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createVersion(docId, req.json), 201);
            return true;
        }
        // GET /v1/documents/{id}/versions/{verId}
        if (seg.length == 2 && seg[0] == "versions" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getVersion(docId, seg[1]), 200);
            return true;
        }

        // POST /v1/documents/{id}/checkout
        if (seg.length == 1 && seg[0] == "checkout" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.checkOutDocument(docId, req.json), 200);
            return true;
        }
        // POST /v1/documents/{id}/checkin
        if (seg.length == 1 && seg[0] == "checkin" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.checkInDocument(docId, req.json), 200);
            return true;
        }
        // POST /v1/documents/{id}/cancel-checkout
        if (seg.length == 1 && seg[0] == "cancel-checkout" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.cancelCheckOut(docId, req.json), 200);
            return true;
        }

        return false;
    }

    // -------------------------------------------------------------------
    // /v1/folders/{id}/...
    // -------------------------------------------------------------------

    private bool routeFolder(string folderId, string[] seg,
                              HTTPServerRequest req, HTTPServerResponse res) {
        // GET /v1/folders/{id}
        if (seg.length == 0 && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getFolder(folderId), 200);
            return true;
        }
        // PUT /v1/folders/{id}
        if (seg.length == 0 && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateFolder(folderId, req.json), 200);
            return true;
        }
        // DELETE /v1/folders/{id}
        if (seg.length == 0 && req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteFolder(folderId), 200);
            return true;
        }

        // POST /v1/folders/{id}/move
        if (seg.length == 1 && seg[0] == "move" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.moveFolder(folderId, req.json), 200);
            return true;
        }
        // POST /v1/folders/{id}/copy
        if (seg.length == 1 && seg[0] == "copy" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.copyFolder(folderId, req.json), 200);
            return true;
        }

        // GET /v1/folders/{id}/properties
        if (seg.length == 1 && seg[0] == "properties" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getFolderProperties(folderId), 200);
            return true;
        }
        // PUT /v1/folders/{id}/properties
        if (seg.length == 1 && seg[0] == "properties" && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateFolderProperties(folderId, req.json), 200);
            return true;
        }

        return false;
    }

    // -------------------------------------------------------------------
    // Auth
    // -------------------------------------------------------------------

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken)
            return;
        if (!("Authorization" in req.headers))
            throw new DMAAuthorizationException("Missing Authorization header");
        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected)
            throw new DMAAuthorizationException("Invalid management token");
    }

    // -------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------

    private string[] normalizedSegments(string subPath) {
        auto clean = subPath;
        if (clean.length > 0 && clean[0] == '/')
            clean = clean[1 .. $];
        if (clean.length > 0 && clean[$ - 1] == '/')
            clean = clean[0 .. $ - 1];
        if (clean.length == 0)
            return [];
        return clean.split("/");
    }

    private void respondError(HTTPServerResponse res, string message, int statusCode) {
        Json payload = Json.emptyObject;
        payload["success"] = false;
        payload["message"] = message;
        payload["statusCode"] = statusCode;
        res.writeJsonBody(payload, statusCode);
    }
}
