module uim.sap.prm.store;

import core.sync.mutex : Mutex;
import std.algorithm.searching : canFind;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMStore : SAPStore {
  private PRMProject[string] _projects;
  private PRMWorkPackage[string] _workPackages;
  private PRMBoardItem[string] _boardItems;
  private PRMPartner[string] _partnersByTenant;
  private PRMPartner[string] _globalPartners;
  private PRMPartnerInvitation[string] _invitations;
  private PRMDeliveryProcess[string] _processes;
  private PRMResource[string] _resources;
  private PRMResourceRequest[string] _resourceRequests;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  PRMProject upsertProject(PRMProject project) {
    synchronized (_lock) {
      auto key = scopedKey(project.tenantId, "project", project.projectId);
      if (auto existing = key in _projects) {
        project.createdAt = existing.createdAt;
      }
      _projects[key] = project;
      return project;
    }
  }

  PRMProject getProject(string tenantId, string projectId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "project", projectId);
      if (auto value = key in _projects) {
        return *value;
      }
    }
    return PRMProject.init;
  }

  bool deleteProject(string tenantId, string projectId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "project", projectId);
      if ((key in _projects) is null) {
        return false;
      }
      _projects.remove(key);
      return true;
    }
  }

  PRMProject[] listProjects(string tenantId) {
    PRMProject[] values;
    synchronized (_lock) {
      foreach (key, value; _projects) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMWorkPackage upsertWorkPackage(PRMWorkPackage workPackage) {
    synchronized (_lock) {
      auto key = scopedKey2(workPackage.tenantId, "work-package", workPackage.projectId, workPackage.workPackageId);
      _workPackages[key] = workPackage;
      return workPackage;
    }
  }

  PRMWorkPackage[] listWorkPackages(string tenantId, string projectId) {
    PRMWorkPackage[] values;
    synchronized (_lock) {
      foreach (key, value; _workPackages) {
        if (belongsTo2(key, tenantId, projectId, "work-package")) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMBoardItem upsertBoardItem(PRMBoardItem item) {
    synchronized (_lock) {
      auto key = scopedKey2(item.tenantId, "board-item", item.projectId, item.itemId);
      _boardItems[key] = item;
      return item;
    }
  }

  PRMBoardItem[] listBoardItems(string tenantId, string projectId) {
    PRMBoardItem[] values;
    synchronized (_lock) {
      foreach (key, value; _boardItems) {
        if (belongsTo2(key, tenantId, projectId, "board-item")) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMPartner upsertGlobalPartner(PRMPartner partner) {
    synchronized (_lock) {
      _globalPartners[partner.partnerId] = partner;
      return partner;
    }
  }

  PRMPartner[] listGlobalPartners() {
    PRMPartner[] values;
    synchronized (_lock) {
      foreach (_id, value; _globalPartners) {
        values ~= value;
      }
    }
    return values;
  }

  PRMPartner upsertTenantPartner(string tenantId, PRMPartner partner) {
    synchronized (_lock) {
      _partnersByTenant[scopedKey(tenantId, "partner", partner.partnerId)] = partner;
      return partner;
    }
  }

  PRMPartner getGlobalPartner(string partnerId) {
    synchronized (_lock) {
      if (auto value = partnerId in _globalPartners) {
        return *value;
      }
    }
    return PRMPartner.init;
  }

  PRMPartner[] listTenantPartners(string tenantId) {
    PRMPartner[] values;
    synchronized (_lock) {
      foreach (key, value; _partnersByTenant) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMPartnerInvitation upsertInvitation(PRMPartnerInvitation invitation) {
    synchronized (_lock) {
      auto key = scopedKey2(invitation.tenantId, "invitation", invitation.projectId, invitation.invitationId);
      _invitations[key] = invitation;
      return invitation;
    }
  }

  PRMPartnerInvitation[] listInvitations(string tenantId, string projectId) {
    PRMPartnerInvitation[] values;
    synchronized (_lock) {
      foreach (key, value; _invitations) {
        if (belongsTo2(key, tenantId, projectId, "invitation")) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMDeliveryProcess upsertDeliveryProcess(PRMDeliveryProcess process) {
    synchronized (_lock) {
      _processes[scopedKey(process.tenantId, "delivery-process", process.processId)] = process;
      return process;
    }
  }

  PRMDeliveryProcess[] listDeliveryProcesses(string tenantId) {
    PRMDeliveryProcess[] values;
    synchronized (_lock) {
      foreach (key, value; _processes) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMResource upsertResource(PRMResource resource) {
    synchronized (_lock) {
      _resources[scopedKey(resource.tenantId, "resource", resource.resourceId)] = resource;
      return resource;
    }
  }

  PRMResource[] listResources(string tenantId) {
    PRMResource[] values;
    synchronized (_lock) {
      foreach (key, value; _resources) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  PRMResourceRequest upsertResourceRequest(PRMResourceRequest request) {
    synchronized (_lock) {
      auto key = scopedKey(request.tenantId, "resource-request", request.requestId);
      _resourceRequests[key] = request;
      return request;
    }
  }

  PRMResourceRequest[] listResourceRequests(string tenantId) {
    PRMResourceRequest[] values;
    synchronized (_lock) {
      foreach (key, value; _resourceRequests) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  private string scopedKey(string tenantId, string scopePart, string id) {
    return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
  }

  private string scopedKey2(string tenantId, string scopePart, string projectId, string id) {
    return tenantId ~ ":" ~ scopePart ~ ":" ~ projectId ~ ":" ~ id;
  }

  private bool belongsTo(string key, string tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
  }

  private bool belongsTo2(string key, string tenantId, string projectId, string scopePart) {
    auto marker = tenantId ~ ":" ~ scopePart ~ ":" ~ projectId ~ ":";
    return key.canFind(marker);
  }
}
