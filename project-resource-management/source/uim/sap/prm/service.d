module uim.sap.prm.service;

import std.array : array;
import std.algorithm.searching : canFind;
import std.datetime : Clock;
import std.string : toLower;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMService : SAPService {
  mixin(SAPServiceTemplate!PRMService);

  private PRMStore _store;

  this(PRMConfig config) {
    super(config);
    _store = new PRMStore;
  }

  Json listGlobalPartners() {
    Json resources = Json.emptyArray;
    foreach (partner; _store.listGlobalPartners()) {
      resources ~= partner.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertGlobalPartner(Json request) {
    PRMPartner partner;
    partner.partnerId = optionalString(request, "partner_id", createId());
    partner.companyName = requiredString(request, "company_name");
    partner.country = optionalString(request, "country", "");
    partner.skills = optionalArray(request, "skills");
    partner.updatedAt = Clock.currTime();

    auto saved = _store.upsertGlobalPartner(partner);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["partner"] = saved.toJson();
    return payload;
  }

  Json listProjects(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (project; _store.listProjects(tenantId)) {
      resources ~= project.toJson();
    }
    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json getProject(string tenantId, string projectId) {
    validateId(tenantId, "Tenant ID");
    validateId(projectId, "Project ID");

    auto project = _store.getProject(tenantId, projectId);
    if (project.projectId.length == 0) {
      throw new PRMNotFoundException("Project", tenantId ~ "/" ~ projectId);
    }

    Json payload = Json.emptyObject;
    payload["project"] = project.toJson();
    return payload;
  }

  Json upsertProject(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    PRMProject project;
    project.tenantId = tenantId;
    project.projectId = optionalString(request, "project_id", createId());
    project.name = requiredString(request, "name");
    project.description = optionalString(request, "description", "");
    project.scheduleStart = optionalString(request, "schedule_start", "");
    project.scheduleEnd = optionalString(request, "schedule_end", "");
    project.deliveryProcessIds = optionalArray(request, "delivery_process_ids");
    project.externalSources = optionalArray(request, "external_sources");
    project.createdAt = Clock.currTime();
    project.updatedAt = project.createdAt;

    auto saved = _store.upsertProject(project);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["project"] = saved.toJson();
    return payload;
  }

  Json deleteProject(string tenantId, string projectId) {
    validateId(tenantId, "Tenant ID");
    validateId(projectId, "Project ID");

    if (!_store.deleteProject(tenantId, projectId)) {
      throw new PRMNotFoundException("Project", tenantId ~ "/" ~ projectId);
    }

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["project_id"] = projectId;
    return payload;
  }

  Json listWorkPackages(string tenantId, string projectId) {
    validateProjectExists(tenantId, projectId);

    Json resources = Json.emptyArray;
    foreach (workPackage; _store.listWorkPackages(tenantId, projectId)) {
      resources ~= workPackage.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    payload["integration_sources"] = "sap-and-third-party";
    return payload;
  }

  Json upsertWorkPackage(string tenantId, string projectId, Json request) {
    validateProjectExists(tenantId, projectId);

    PRMWorkPackage workPackage;
    workPackage.tenantId = tenantId;
    workPackage.projectId = projectId;
    workPackage.workPackageId = optionalString(request, "work_package_id", createId());
    workPackage.sourceSystem = optionalString(request, "source_system", "sap");
    workPackage.externalId = optionalString(request, "external_id", "");
    workPackage.title = requiredString(request, "title");
    workPackage.status = optionalString(request, "status", "planned");
    workPackage.ownerCompanies = optionalArray(request, "owner_companies");
    workPackage.schedule = optionalObject(request, "schedule");
    workPackage.updatedAt = Clock.currTime();

    auto saved = _store.upsertWorkPackage(workPackage);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["work_package"] = saved.toJson();
    return payload;
  }

  Json listBoardItems(string tenantId, string projectId) {
    validateProjectExists(tenantId, projectId);

    Json resources = Json.emptyArray;
    Json counts = Json.emptyObject;
    counts["task"] = 0;
    counts["deliverable"] = 0;
    counts["issue"] = 0;
    counts["punch-list"] = 0;

    foreach (item; _store.listBoardItems(tenantId, projectId)) {
      resources ~= item.toJson();
      if (item.itemType in counts) {
        counts[item.itemType] = counts[item.itemType].get!long + 1;
      }
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["counts"] = counts;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertBoardItem(string tenantId, string projectId, Json request) {
    validateProjectExists(tenantId, projectId);

    PRMBoardItem item;
    item.tenantId = tenantId;
    item.projectId = projectId;
    item.itemId = optionalString(request, "item_id", createId());
    item.itemType = normalizeItemType(requiredString(request, "item_type"));
    item.title = requiredString(request, "title");
    item.status = optionalString(request, "status", "open");
    item.assigneeCompany = optionalString(request, "assignee_company", "");
    item.metadata = optionalObject(request, "metadata");
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertBoardItem(item);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["board_item"] = saved.toJson();
    return payload;
  }

  Json listTenantPartners(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (partner; _store.listTenantPartners(tenantId)) {
      resources ~= partner.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json linkTenantPartner(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto partnerId = requiredString(request, "partner_id");
    auto globalPartner = _store.getGlobalPartner(partnerId);
    if (globalPartner.partnerId.length == 0) {
      throw new PRMNotFoundException("Business partner", partnerId);
    }

    auto saved = _store.upsertTenantPartner(tenantId, globalPartner);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["partner"] = saved.toJson();
    payload["message"] = "Partner linked to tenant collaboration space";
    return payload;
  }

  Json invitePartner(string tenantId, string projectId, Json request) {
    validateProjectExists(tenantId, projectId);
    auto partnerId = requiredString(request, "partner_id");
    auto email = requiredString(request, "email");

    auto linked = _store.getGlobalPartner(partnerId);
    if (linked.partnerId.length == 0) {
      throw new PRMNotFoundException("Business partner", partnerId);
    }

    PRMPartnerInvitation invitation;
    invitation.tenantId = tenantId;
    invitation.projectId = projectId;
    invitation.invitationId = createId();
    invitation.partnerId = partnerId;
    invitation.email = email;
    invitation.status = "sent";
    invitation.invitedAt = Clock.currTime();

    auto saved = _store.upsertInvitation(invitation);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["invitation"] = saved.toJson();
    payload["message"] = "Collaboration invitation sent";
    return payload;
  }

  Json listDeliveryProcesses(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (process; _store.listDeliveryProcesses(tenantId)) {
      resources ~= process.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertDeliveryProcess(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    PRMDeliveryProcess process;
    process.tenantId = tenantId;
    process.processId = optionalString(request, "process_id", createId());
    process.name = requiredString(request, "name");
    process.phases = optionalArray(request, "phases");
    process.updatedAt = Clock.currTime();

    auto saved = _store.upsertDeliveryProcess(process);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["delivery_process"] = saved.toJson();
    payload["repeatable_process"] = true;
    return payload;
  }

  Json listResources(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (resource; _store.listResources(tenantId)) {
      resources ~= resource.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertResource(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto cfg = cast(PRMConfig)_config;

    PRMResource resource;
    resource.tenantId = tenantId;
    resource.resourceId = optionalString(request, "resource_id", createId());
    resource.fullName = requiredString(request, "full_name");
    resource.company = requiredString(request, "company");
    resource.skills = optionalArray(request, "skills");
    resource.availabilityHours = optionalDouble(request, "availability_hours", cfg.defaultCapacityHours);
    resource.updatedAt = Clock.currTime();

    auto saved = _store.upsertResource(resource);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["resource"] = saved.toJson();
    return payload;
  }

  Json searchResourcesBySkills(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto requiredSkills = optionalArray(request, "skills");
    auto minimumHours = optionalDouble(request, "minimum_hours", 0);

    Json matches = Json.emptyArray;
    foreach (resource; _store.listResources(tenantId)) {
      if (!hasRequiredSkills(resource.skills, requiredSkills)) {
        continue;
      }
      if (resource.availabilityHours < minimumHours) {
        continue;
      }
      matches ~= resource.toJson();
    }

    Json payload = Json.emptyObject;
    payload["skills"] = requiredSkills;
    payload["minimum_hours"] = minimumHours;
    payload["matches"] = matches;
    payload["total_results"] = cast(long)matches.length;
    return payload;
  }

  Json resourceCapacity(string tenantId) {
    validateId(tenantId, "Tenant ID");

    auto resources = _store.listResources(tenantId);
    auto requests = _store.listResourceRequests(tenantId);

    double totalHours = 0;
    double requestedHours = 0;
    foreach (resource; resources) {
      totalHours += resource.availabilityHours;
    }
    foreach (request; requests) {
      if (request.status == "open" || request.status == "approved") {
        requestedHours += request.requiredHours;
      }
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resource_count"] = cast(long)resources.length;
    payload["request_count"] = cast(long)requests.length;
    payload["capacity_total_hours"] = totalHours;
    payload["requested_hours"] = requestedHours;
    payload["free_hours"] = totalHours - requestedHours;
    payload["timestamp"] = Clock.currTime().toISOExtString();
    return payload;
  }

  Json listResourceRequests(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (request; _store.listResourceRequests(tenantId)) {
      resources ~= request.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    payload["central_queue"] = true;
    return payload;
  }

  Json upsertResourceRequest(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    PRMResourceRequest resourceRequest;
    resourceRequest.tenantId = tenantId;
    resourceRequest.requestId = optionalString(request, "request_id", createId());
    resourceRequest.projectId = requiredString(request, "project_id");
    resourceRequest.requestedSkills = optionalArray(request, "requested_skills");
    resourceRequest.requiredHours = optionalDouble(request, "required_hours", 8);
    resourceRequest.status = optionalString(request, "status", "open");
    resourceRequest.updatedAt = Clock.currTime();

    validateProjectExists(tenantId, resourceRequest.projectId);

    auto saved = _store.upsertResourceRequest(resourceRequest);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["resource_request"] = saved.toJson();
    return payload;
  }

  Json matchResourcesForProject(string tenantId, string projectId, Json request) {
    validateProjectExists(tenantId, projectId);

    Json skills = optionalArray(request, "skills");
    auto requiredHours = optionalDouble(request, "required_hours", 0);

    Json matches = Json.emptyArray;
    foreach (resource; _store.listResources(tenantId)) {
      if (!hasRequiredSkills(resource.skills, skills)) {
        continue;
      }
      if (resource.availabilityHours < requiredHours) {
        continue;
      }

      auto score = overlapCount(resource.skills, skills);
      Json scored = resource.toJson();
      scored["match_score"] = score;
      matches ~= scored;
    }

    Json payload = Json.emptyObject;
    payload["project_id"] = projectId;
    payload["required_skills"] = skills;
    payload["required_hours"] = requiredHours;
    payload["matches"] = matches;
    payload["total_results"] = cast(long)matches.length;
    return payload;
  }

  private void validateProjectExists(string tenantId, string projectId) {
    validateId(tenantId, "Tenant ID");
    validateId(projectId, "Project ID");
    auto project = _store.getProject(tenantId, projectId);
    if (project.projectId.length == 0) {
      throw new PRMNotFoundException("Project", tenantId ~ "/" ~ projectId);
    }
  }

  private string requiredString(Json request, string key) {
    if (!(key in request) || !request[key].isString) {
      throw new PRMValidationException(key ~ " is required");
    }
    auto value = request[key].get!string;
    if (value.length == 0) {
      throw new PRMValidationException(key ~ " cannot be empty");
    }
    return value;
  }

  private string optionalString(Json request, string key, string fallback) {
    if (key in request && request[key].isString) {
      return request[key].get!string;
    }
    return fallback;
  }

  private Json optionalArray(Json request, string key) {
    if (key in request && request[key].isArray) {
      return request[key];
    }
    return Json.emptyArray;
  }

  private Json optionalObject(Json request, string key) {
    if (key in request && request[key].isObject) {
      return request[key];
    }
    return Json.emptyObject;
  }

  private double optionalDouble(Json request, string key, double fallback) {
    if (!(key in request)) {
      return fallback;
    }

    try {
      if (request[key].isInteger) {
        return cast(double)request[key].get!long;
      }
      return request[key].get!double;
    } catch (Exception) {
      return fallback;
    }
  }

  private string normalizeItemType(string rawItemType) {
    auto itemType = toLower(rawItemType);
    if (itemType != "task" && itemType != "deliverable" && itemType != "issue" && itemType != "punch-list") {
      throw new PRMValidationException("item_type must be task, deliverable, issue, or punch-list");
    }
    return itemType;
  }

  private bool hasRequiredSkills(Json resourceSkills, Json requestedSkills) {
    if (requestedSkills.type != Json.Type.array || requestedSkills.length == 0) {
      return true;
    }

    auto resource = toLoweredStringArray(resourceSkills);
    foreach (skillItem; requestedSkills.get!(Json[])) {
      if (!skillItem.isString) {
        continue;
      }
      auto needed = toLower(skillItem.get!string);
      if (!resource.canFind(needed)) {
        return false;
      }
    }
    return true;
  }

  private long overlapCount(Json resourceSkills, Json requestedSkills) {
    if (requestedSkills.type != Json.Type.array) {
      return 0;
    }

    long count = 0;
    auto resource = toLoweredStringArray(resourceSkills);
    foreach (skillItem; requestedSkills.get!(Json[])) {
      if (!skillItem.isString) {
        continue;
      }
      auto needed = toLower(skillItem.get!string);
      if (resource.canFind(needed)) {
        count++;
      }
    }
    return count;
  }

  private string[] toLoweredStringArray(Json values) {
    string[] result;
    if (values.type != Json.Type.array) {
      return result;
    }
    foreach (item; values.get!(Json[])) {
      if (item.isString) {
        result ~= toLower(item.get!string);
      }
    }
    return result.array;
  }

  private void validateId(string value, string fieldName) {
    if (value.length == 0) {
      throw new PRMValidationException(fieldName ~ " cannot be empty");
    }
  }
}
