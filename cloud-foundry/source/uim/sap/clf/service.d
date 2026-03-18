/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.service;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

class CLFService : SAPService {
  mixin(SAPServiceTemplate!CLFService);

  private CLFStore _store;

  this(CLFConfig config) {
    super(config);
    _store = new CLFStore;
    _store.seedServiceOfferings();
  }

  Json createOrganization(Json request) {
    auto org = CLFOrg(request);
    if (org.name.length == 0) {
      throw new CLFValidationException("Organization name is required");
    }
    auto created = _store.createOrg(org);
    return created.toJson();
  }

  Json listOrganizations() {
    Json resources = _store.listOrgs().map!(org => org.toJson()).array.toJson;

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.listOrgs().length;
    return payload;
  }

  Json createSpace(Json request) {
    auto space = CLFSpace(request);
    if (space.name.length == 0) {
      throw new CLFValidationException("Space name is required");
    }
    if (space.organizationGuid.length == 0) {
      throw new CLFValidationException("organization_guid is required");
    }
    if (!_store.hasOrg(space.organizationGuid)) {
      throw new CLFNotFoundException("Organization", space.organizationGuid);
    }
    auto created = _store.createSpace(space);
    return created.toJson();
  }

  Json listSpaces() {
    Json resources = _store.listSpaces().map!(space => space.toJson()).array.toJson;

    return Json.emptyObject
    .set("resources", resources)
    .set("total_results", cast(long)_store.listSpaces().length);
  }

  Json createApp(Json request) {
    auto app = CLFApp(request);
    if (app.name.length == 0) {
      throw new CLFValidationException("App name is required");
    }
    if (app.spaceGuid.length == 0) {
      throw new CLFValidationException("space_guid is required");
    }
    if (!_store.hasSpace(app.spaceGuid)) {
      throw new CLFNotFoundException("Space", app.spaceGuid);
    }

    auto created = _store.createApp(app);
    return created.toJson();
  }

  Json listApps() {
    Json resources = _store.listApps().map!(app => app.toJson()).array.toJson;

    return Json.emptyObject
    .set("resources", resources)
    .set("total_results", cast(long)_store.listApps().length);
  }

  Json getApp(string guid) {
    auto app = _store.getApp(guid);
    if (app.guid.length == 0) {
      throw new CLFNotFoundException("App", guid);
    }
    return app.toJson();
  }

  Json listServiceOfferings() {
    Json resources = _store.listServiceOfferings().map!(offering => offering.toJson()).array.toJson;

    return Json.emptyObject
    .set("resources", resources)
    .set("total_results", cast(long)_store.listServiceOfferings().length);
  }

  Json createServiceInstance(Json request) {
    auto instance = CLFServiceInstance(request);
    if (instance.name.length == 0) {
      throw new CLFValidationException("Service instance name is required");
    }
    if (instance.spaceGuid.length == 0) {
      throw new CLFValidationException("space_guid is required");
    }
    if (instance.serviceGuid.length == 0) {
      throw new CLFValidationException("service_guid is required");
    }
    if (!_store.hasSpace(instance.spaceGuid)) {
      throw new CLFNotFoundException("Space", instance.spaceGuid);
    }
    if (!_store.hasServiceOffering(instance.serviceGuid)) {
      throw new CLFNotFoundException("Service offering", instance.serviceGuid);
    }

    auto created = _store.createServiceInstance(instance);
    return created.toJson();
  }

  Json listServiceInstances() {
    Json resources = _store.listServiceInstances().map!(instance => instance.toJson()).array.toJson;

    return Json.emptyObject
    .set("resources", resources)
    .set("total_results", cast(long)_store.listServiceInstances().length);
  }
}
