module uim.sap.prm.models.models;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

struct PRMProject {
  string tenantId;
  string projectId;
  string name;
  string description;
  string scheduleStart;
  string scheduleEnd;
  Json deliveryProcessIds;
  Json externalSources;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["project_id"] = projectId;
    payload["name"] = name;
    payload["description"] = description;
    payload["schedule_start"] = scheduleStart;
    payload["schedule_end"] = scheduleEnd;
    payload["delivery_process_ids"] = deliveryProcessIds;
    payload["external_sources"] = externalSources;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct PRMWorkPackage {
  string tenantId;
  string projectId;
  string workPackageId;
  string sourceSystem;
  string externalId;
  string title;
  string status;
  Json ownerCompanies;
  Json schedule;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["project_id"] = projectId;
    payload["work_package_id"] = workPackageId;
    payload["source_system"] = sourceSystem;
    payload["external_id"] = externalId;
    payload["title"] = title;
    payload["status"] = status;
    payload["owner_companies"] = ownerCompanies;
    payload["schedule"] = schedule;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct PRMBoardItem {
  string tenantId;
  string projectId;
  string itemId;
  string itemType;
  string title;
  string status;
  string assigneeCompany;
  Json metadata;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["project_id"] = projectId;
    payload["item_id"] = itemId;
    payload["item_type"] = itemType;
    payload["title"] = title;
    payload["status"] = status;
    payload["assignee_company"] = assigneeCompany;
    payload["metadata"] = metadata;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct PRMPartner {
  string partnerId;
  string companyName;
  string country;
  Json skills;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["partner_id"] = partnerId;
    payload["company_name"] = companyName;
    payload["country"] = country;
    payload["skills"] = skills;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct PRMPartnerInvitation {
  string tenantId;
  string projectId;
  string invitationId;
  string partnerId;
  string email;
  string status;
  SysTime invitedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["project_id"] = projectId;
    payload["invitation_id"] = invitationId;
    payload["partner_id"] = partnerId;
    payload["email"] = email;
    payload["status"] = status;
    payload["invited_at"] = invitedAt.toISOExtString();
    return payload;
  }
}

struct PRMDeliveryProcess {
  string tenantId;
  string processId;
  string name;
  Json phases;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["process_id"] = processId;
    payload["name"] = name;
    payload["phases"] = phases;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct PRMResource {
  string tenantId;
  string resourceId;
  string fullName;
  string company;
  Json skills;
  double availabilityHours;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resource_id"] = resourceId;
    payload["full_name"] = fullName;
    payload["company"] = company;
    payload["skills"] = skills;
    payload["availability_hours"] = availabilityHours;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct PRMResourceRequest {
  string tenantId;
  string requestId;
  string projectId;
  Json requestedSkills;
  double requiredHours;
  string status;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["request_id"] = requestId;
    payload["project_id"] = projectId;
    payload["requested_skills"] = requestedSkills;
    payload["required_hours"] = requiredHours;
    payload["status"] = status;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
