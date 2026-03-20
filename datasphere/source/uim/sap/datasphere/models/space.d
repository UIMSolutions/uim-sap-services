/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.space;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Represents a space in the Datasphere application.
  *
  * A space is a logical container for organizing data models, business models, and other related resources within a tenant. It provides isolation and management capabilities for these resources.   
  * Fields:
  * - tenantId: The ID of the tenant this space belongs to.
  * - spaceId: A unique identifier for the space.
  * - name: The name of the space.
  * - diskGb: The amount of disk space allocated to this space in gigabytes.
  * - memoryGb: The amount of memory allocated to this space in gigabytes.
  * - priority: The priority level of the space, which may affect resource allocation and scheduling.
  * - users: An array of user IDs that have access to this space.
  * - active: A boolean indicating whether the space is currently active.
  * - updatedAt: The timestamp of the last update to this space.
 */
struct DATSpace {
  UUID tenantId;
  string spaceId;
  string name;
  int diskGb;
  int memoryGb;
  int priority;
  string[] users;
  bool active;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    Json usersPayload = Json.emptyArray;
    foreach (user; users)
      usersPayload ~= user;

    payload["tenant_id"] = tenantId;
    payload["space_id"] = spaceId;
    payload["name"] = name;
    payload["disk_gb"] = diskGb;
    payload["memory_gb"] = memoryGb;
    payload["priority"] = priority;
    payload["users"] = usersPayload;
    payload["active"] = active;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
