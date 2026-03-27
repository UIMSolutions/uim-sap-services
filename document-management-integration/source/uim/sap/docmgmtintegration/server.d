module uim.sap.docmgmtintegration.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.docmgmtintegration.exceptions;
import uim.sap.docmgmtintegration.service;

/**
 * HTTP server for the Document Management Integration Service.
 *
 * All tenant-scoped resources live under:
 *   /api/docmgmt-integration/v1/tenants/{tenantId}/...
 *
 * Global admin endpoints:
 *   POST   /api/docmgmt-integration/v1/tenants           - create tenant
 *   GET    /api/docmgmt-integration/v1/tenants           - list tenants
 *   GET    /api/docmgmt-integration/v1/encryption/status  - encryption info
 *   GET    /api/docmgmt-integration/health                - health probe
 *   GET    /api/docmgmt-integration/ready                 - readiness probe
 */
class DocMgmtIntegrationServer : SAPServer {
  mixin(SAPServerTemplate!DocMgmtIntegrationServer);

  private DocMgmtIntegrationService _service;

  this(DocMgmtIntegrationService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    // All other endpoints require auth
    try {
      validateAuth(req, _service.config);
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

    } catch (DocMgmtIntegrationTenantRequiredException e) {
      respondError(res, e.msg, 400);
    } catch (DocMgmtIntegrationAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DocMgmtIntegrationNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DocMgmtIntegrationConflictException e) {
      respondError(res, e.msg, 409);
    } catch (DocMgmtIntegrationPayloadTooLargeException e) {
      respondError(res, e.msg, 413);
    } catch (DocMgmtIntegrationValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DocMgmtIntegrationException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  // -------------------------------------------------------------------
  // V1 route dispatcher
  // -------------------------------------------------------------------

  private bool routeV1(string[] seg, HTTPServerRequest req, HTTPServerResponse res) {
    // /v1/tenants
    if (seg.length >= 1 && seg[0] == "tenants") {
      return routeTenants(seg[1 .. $], req, res);
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
  // /v1/tenants[/...]
  // -------------------------------------------------------------------

  private bool routeTenants(string[] seg, HTTPServerRequest req, HTTPServerResponse res) {
    // POST /v1/tenants  — create tenant
    if (seg.length == 0 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createTenant(req.json), 201);
      return true;
    }
    // GET /v1/tenants  — list tenants
    if (seg.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listTenants(), 200);
      return true;
    }

    if (seg.length < 1)
      return false;
    auto tenantId = seg[0];

    // GET /v1/tenants/{id}
    if (seg.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getTenant(tenantId), 200);
      return true;
    }
    // PUT /v1/tenants/{id}
    if (seg.length == 1 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateTenant(tenantId, req.json), 200);
      return true;
    }
    // DELETE /v1/tenants/{id}
    if (seg.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteTenant(tenantId), 200);
      return true;
    }

    // Tenant-scoped sub-resources
    if (seg.length >= 2) {
      return routeTenantSubResources(tenantId, seg[1 .. $], req, res);
    }

    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tenantId}/{resource}[/...]
  // -------------------------------------------------------------------

  private bool routeTenantSubResources(UUID tenantId, string[] seg,
    HTTPServerRequest req,
    HTTPServerResponse res) {
    if (seg.length < 1)
      return false;

    // /v1/tenants/{tid}/repositories[/...]
    if (seg[0] == "repositories") {
      return routeRepositories(tenantId, seg[1 .. $], req, res);
    }

    // /v1/tenants/{tid}/documents/{docId}/...
    if (seg[0] == "documents" && seg.length >= 2) {
      return routeDocument(tenantId, seg[1], seg[2 .. $], req, res);
    }

    // /v1/tenants/{tid}/folders/{folderId}/...
    if (seg[0] == "folders" && seg.length >= 2) {
      return routeFolder(tenantId, seg[1], seg[2 .. $], req, res);
    }

    // /v1/tenants/{tid}/ui-component
    if (seg[0] == "ui-component") {
      return routeUIComponent(tenantId, seg[1 .. $], req, res);
    }

    // /v1/tenants/{tid}/links[/...]
    if (seg[0] == "links") {
      return routeLinks(tenantId, seg[1 .. $], req, res);
    }

    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/repositories[/...]
  // -------------------------------------------------------------------

  private bool routeRepositories(UUID tenantId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // GET /v1/tenants/{tid}/repositories
    if (seg.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listRepositories(tenantId), 200);
      return true;
    }
    // POST /v1/tenants/{tid}/repositories
    if (seg.length == 0 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.connectRepository(tenantId, req.json), 201);
      return true;
    }

    if (seg.length < 1)
      return false;
    auto repoId = seg[0];

    // GET /v1/tenants/{tid}/repositories/{id}
    if (seg.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getRepository(tenantId, repoId), 200);
      return true;
    }
    // DELETE /v1/tenants/{tid}/repositories/{id}
    if (seg.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.disconnectRepository(tenantId, repoId), 200);
      return true;
    }

    // /v1/tenants/{tid}/repositories/{id}/folders[/...]
    if (seg.length >= 2 && seg[1] == "folders") {
      return routeRepoFolders(tenantId, repoId, seg[2 .. $], req, res);
    }

    // /v1/tenants/{tid}/repositories/{id}/documents[/...]
    if (seg.length >= 2 && seg[1] == "documents") {
      return routeRepoDocuments(tenantId, repoId, seg[2 .. $], req, res);
    }

    // /v1/tenants/{tid}/repositories/{id}/contents?folder_id=...
    if (seg.length == 2 && seg[1] == "contents" && req.method == HTTPMethod.GET) {
      string folderId = "";
      if ("folder_id" in req.query)
        folderId = req.query["folder_id"];
      res.writeJsonBody(_service.listFolderContents(tenantId, repoId, folderId), 200);
      return true;
    }

    // /v1/tenants/{tid}/repositories/{id}/contents/sorted
    if (seg.length == 3 && seg[1] == "contents" && seg[2] == "sorted"
      && req.method == HTTPMethod.POST) {
      string folderId = "";
      auto body_ = req.json;
      if ("folder_id" in body_ && body_["folder_id"].isString)
        folderId = body_["folder_id"].getString;
      res.writeJsonBody(
        _service.listDocumentsSorted(tenantId, repoId, folderId, body_), 200);
      return true;
    }

    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/repositories/{repoId}/folders[/...]
  // -------------------------------------------------------------------

  private bool routeRepoFolders(UUID tenantId, string repoId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // POST /v1/tenants/{tid}/repositories/{id}/folders
    if (seg.length == 0 && req.method == HTTPMethod.POST) {
      string parentId = "";
      if ("parent_folder_id" in req.query)
        parentId = req.query["parent_folder_id"];
      auto body_ = req.json;
      if ("parent_folder_id" in body_ && body_["parent_folder_id"].isString)
        parentId = body_["parent_folder_id"].getString;
      res.writeJsonBody(
        _service.createFolder(tenantId, repoId, parentId, body_), 201);
      return true;
    }
    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/repositories/{repoId}/documents[/...]
  // -------------------------------------------------------------------

  private bool routeRepoDocuments(UUID tenantId, string repoId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // POST /v1/tenants/{tid}/repositories/{id}/documents
    if (seg.length == 0 && req.method == HTTPMethod.POST) {
      string folderId = "";
      if ("folder_id" in req.query)
        folderId = req.query["folder_id"];
      auto body_ = req.json;
      if ("folder_id" in body_ && body_["folder_id"].isString)
        folderId = body_["folder_id"].getString;
      res.writeJsonBody(
        _service.createDocument(tenantId, repoId, folderId, body_), 201);
      return true;
    }
    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/documents/{docId}/...
  // -------------------------------------------------------------------

  private bool routeDocument(UUID tenantId, string docId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // GET /v1/tenants/{tid}/documents/{id}
    if (seg.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getDocument(tenantId, docId), 200);
      return true;
    }
    // PUT /v1/tenants/{tid}/documents/{id}
    if (seg.length == 0 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateDocument(tenantId, docId, req.json), 200);
      return true;
    }
    // DELETE /v1/tenants/{tid}/documents/{id}
    if (seg.length == 0 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteDocument(tenantId, docId), 200);
      return true;
    }

    // POST .../move
    if (seg.length == 1 && seg[0] == "move" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.moveDocument(tenantId, docId, req.json), 200);
      return true;
    }
    // POST .../copy
    if (seg.length == 1 && seg[0] == "copy" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.copyDocument(tenantId, docId, req.json), 200);
      return true;
    }

    // GET .../view
    if (seg.length == 1 && seg[0] == "view" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.viewDocument(tenantId, docId), 200);
      return true;
    }
    // GET .../download
    if (seg.length == 1 && seg[0] == "download" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.downloadDocument(tenantId, docId), 200);
      return true;
    }

    // GET .../metadata
    if (seg.length == 1 && seg[0] == "metadata" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getDocumentMetadata(tenantId, docId), 200);
      return true;
    }
    // PUT .../metadata
    if (seg.length == 1 && seg[0] == "metadata" && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateDocumentMetadata(tenantId, docId, req.json), 200);
      return true;
    }

    // GET .../versions
    if (seg.length == 1 && seg[0] == "versions" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listVersions(tenantId, docId), 200);
      return true;
    }
    // POST .../versions
    if (seg.length == 1 && seg[0] == "versions" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createVersion(tenantId, docId, req.json), 201);
      return true;
    }
    // GET .../versions/{verId}
    if (seg.length == 2 && seg[0] == "versions" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getVersion(tenantId, docId, seg[1]), 200);
      return true;
    }

    // GET .../links  — links pointing to this document
    if (seg.length == 1 && seg[0] == "links" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listLinksByDocument(tenantId, docId), 200);
      return true;
    }

    // POST .../checkout
    if (seg.length == 1 && seg[0] == "checkout" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.checkOutDocument(tenantId, docId, req.json), 200);
      return true;
    }
    // POST .../checkin
    if (seg.length == 1 && seg[0] == "checkin" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.checkInDocument(tenantId, docId, req.json), 200);
      return true;
    }
    // POST .../cancel-checkout
    if (seg.length == 1 && seg[0] == "cancel-checkout" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.cancelCheckOut(tenantId, docId, req.json), 200);
      return true;
    }

    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/folders/{folderId}/...
  // -------------------------------------------------------------------

  private bool routeFolder(UUID tenantId, string folderId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // GET /v1/tenants/{tid}/folders/{id}
    if (seg.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getFolder(tenantId, folderId), 200);
      return true;
    }
    // PUT /v1/tenants/{tid}/folders/{id}
    if (seg.length == 0 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateFolder(tenantId, folderId, req.json), 200);
      return true;
    }
    // DELETE /v1/tenants/{tid}/folders/{id}
    if (seg.length == 0 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteFolder(tenantId, folderId), 200);
      return true;
    }

    // POST .../move
    if (seg.length == 1 && seg[0] == "move" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.moveFolder(tenantId, folderId, req.json), 200);
      return true;
    }
    // POST .../copy
    if (seg.length == 1 && seg[0] == "copy" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.copyFolder(tenantId, folderId, req.json), 200);
      return true;
    }

    // GET .../properties
    if (seg.length == 1 && seg[0] == "properties" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getFolderProperties(tenantId, folderId), 200);
      return true;
    }
    // PUT .../properties
    if (seg.length == 1 && seg[0] == "properties" && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateFolderProperties(tenantId, folderId, req.json), 200);
      return true;
    }

    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/ui-component
  // -------------------------------------------------------------------

  private bool routeUIComponent(UUID tenantId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // GET /v1/tenants/{tid}/ui-component
    if (seg.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getUIComponentConfig(tenantId), 200);
      return true;
    }
    // PUT /v1/tenants/{tid}/ui-component
    if (seg.length == 0 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.setUIComponentConfig(tenantId, req.json), 200);
      return true;
    }
    // DELETE /v1/tenants/{tid}/ui-component
    if (seg.length == 0 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteUIComponentConfig(tenantId), 200);
      return true;
    }
    return false;
  }

  // -------------------------------------------------------------------
  // /v1/tenants/{tid}/links[/...]
  // -------------------------------------------------------------------

  private bool routeLinks(UUID tenantId, string[] seg,
    HTTPServerRequest req, HTTPServerResponse res) {
    // POST /v1/tenants/{tid}/links  — create link
    if (seg.length == 0 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createLink(tenantId, req.json), 201);
      return true;
    }
    // GET /v1/tenants/{tid}/links  — list links
    if (seg.length == 0 && req.method == HTTPMethod.GET) {
      // Check for query param filters
      string objectType = "";
      string objectId = "";
      if ("external_object_type" in req.query)
        objectType = req.query["external_object_type"];
      if ("external_object_id" in req.query)
        objectId = req.query["external_object_id"];

      if (objectType.length > 0 && objectId.length > 0) {
        res.writeJsonBody(
          _service.listLinksByObject(tenantId, objectType, objectId), 200);
      } else {
        res.writeJsonBody(_service.listLinks(tenantId), 200);
      }
      return true;
    }

    if (seg.length < 1)
      return false;
    auto linkId = seg[0];

    // GET /v1/tenants/{tid}/links/{id}
    if (seg.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getLink(tenantId, linkId), 200);
      return true;
    }
    // DELETE /v1/tenants/{tid}/links/{id}
    if (seg.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteLink(tenantId, linkId), 200);
      return true;
    }

    return false;
  }
}
