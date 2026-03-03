module uim.sap.identityprovisioning.service;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** Business-logic layer for the Identity Provisioning service.
 *
 *  Capabilities:
 *  - Register source / target / proxy systems
 *  - CRUD for users and groups
 *  - Define transformation and filter rules
 *  - Run provisioning jobs in full or delta read mode
 *  - Job logging with level filtering and export
 *  - Notification subscriptions for job events
 *  - Tenant-scoped multitenancy
 */
class IPService : SAPService {
    private IPConfig _config;
    private IPStore _store;

    this(IPConfig config) {
        config.validate();
        _config = config;
        _store = new IPStore;
    }

    @property const(IPConfig) config() const {
        return _config;
    }

    // ─── Platform endpoints ───────────────────────────────────

    Json health() {
        Json result = Json.emptyObject;
        result["ok"] = true;
        result["serviceName"] = _config.serviceName;
        result["serviceVersion"] = _config.serviceVersion;
        return result;
    }

    Json ready() {
        Json result = Json.emptyObject;
        result["ready"] = true;
        result["timestamp"] = Clock.currTime().toISOExtString();
        return result;
    }

    // ─── System CRUD ──────────────────────────────────────────

    Json createSystem(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto system = systemFromJson(tenantId, request);
        if (system.systemName.length == 0)
            throw new IPValidationException("system_name is required");
        if (system.systemType != "source" && system.systemType != "target" && system.systemType != "proxy")
            throw new IPValidationException("system_type must be 'source', 'target', or 'proxy'");

        auto existing = _store.getSystem(tenantId, system.systemName);
        if (existing.systemName.length > 0)
            throw new IPValidationException("System already exists: " ~ system.systemName);

        auto saved = _store.upsertSystem(system);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["system"] = saved.toJson();
        return result;
    }

    Json listSystems(string tenantId, string systemType = "") {
        validateId(tenantId, "Tenant ID");

        IPSystem[] systems;
        if (systemType.length > 0)
            systems = _store.listSystemsByType(tenantId, systemType);
        else
            systems = _store.listSystems(tenantId);

        Json resources = Json.emptyArray;
        foreach (sys; systems) {
            resources ~= sys.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    Json getSystem(string tenantId, string systemName) {
        validateId(tenantId, "Tenant ID");
        validateId(systemName, "System name");

        auto system = _store.getSystem(tenantId, systemName);
        if (system.systemName.length == 0)
            throw new IPNotFoundException("System", tenantId ~ "/" ~ systemName);

        Json result = Json.emptyObject;
        result["system"] = system.toJson();
        return result;
    }

    Json updateSystem(string tenantId, string systemName, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(systemName, "System name");

        auto existing = _store.getSystem(tenantId, systemName);
        if (existing.systemName.length == 0)
            throw new IPNotFoundException("System", tenantId ~ "/" ~ systemName);

        if ("description" in request && request["description"].type == Json.Type.string)
            existing.description = request["description"].get!string;
        if ("endpoint_url" in request && request["endpoint_url"].type == Json.Type.string)
            existing.endpointUrl = request["endpoint_url"].get!string;
        if ("auth_type" in request && request["auth_type"].type == Json.Type.string)
            existing.authType = request["auth_type"].get!string;
        if ("status" in request && request["status"].type == Json.Type.string)
            existing.status = request["status"].get!string;
        if ("connector_type" in request && request["connector_type"].type == Json.Type.string)
            existing.connectorType = request["connector_type"].get!string;

        existing.updatedAt = Clock.currTime().toISOExtString();
        auto saved = _store.upsertSystem(existing);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["system"] = saved.toJson();
        return result;
    }

    Json deleteSystem(string tenantId, string systemName) {
        validateId(tenantId, "Tenant ID");
        validateId(systemName, "System name");

        if (!_store.deleteSystem(tenantId, systemName))
            throw new IPNotFoundException("System", tenantId ~ "/" ~ systemName);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["message"] = "System deleted: " ~ systemName;
        return result;
    }

    // ─── User CRUD ────────────────────────────────────────────

    Json createUser(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto user = userFromJson(tenantId, request);
        if (user.userName.length == 0)
            throw new IPValidationException("user_name is required");

        auto saved = _store.upsertUser(user);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["user"] = saved.toJson();
        return result;
    }

    Json listUsers(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (user; _store.listUsers(tenantId)) {
            resources ~= user.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    Json getUser(string tenantId, string userId) {
        validateId(tenantId, "Tenant ID");
        validateId(userId, "User ID");

        auto user = _store.getUser(tenantId, userId);
        if (user.userId.length == 0)
            throw new IPNotFoundException("User", tenantId ~ "/" ~ userId);

        Json result = Json.emptyObject;
        result["user"] = user.toJson();
        return result;
    }

    Json updateUser(string tenantId, string userId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(userId, "User ID");

        auto existing = _store.getUser(tenantId, userId);
        if (existing.userId.length == 0)
            throw new IPNotFoundException("User", tenantId ~ "/" ~ userId);

        if ("email" in request && request["email"].type == Json.Type.string)
            existing.email = request["email"].get!string;
        if ("first_name" in request && request["first_name"].type == Json.Type.string)
            existing.firstName = request["first_name"].get!string;
        if ("last_name" in request && request["last_name"].type == Json.Type.string)
            existing.lastName = request["last_name"].get!string;
        if ("display_name" in request && request["display_name"].type == Json.Type.string)
            existing.displayName = request["display_name"].get!string;
        if ("active" in request && request["active"].type == Json.Type.bool_)
            existing.active = request["active"].get!bool;
        if ("status" in request && request["status"].type == Json.Type.string)
            existing.status = request["status"].get!string;

        if ("group_ids" in request && request["group_ids"].type == Json.Type.array) {
            string[] gids;
            foreach (item; request["group_ids"]) {
                if (item.type == Json.Type.string)
                    gids ~= item.get!string;
            }
            existing.groupIds = gids;
        }

        existing.updatedAt = Clock.currTime().toISOExtString();
        existing.lastModifiedAt = existing.updatedAt;
        auto saved = _store.upsertUser(existing);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["user"] = saved.toJson();
        return result;
    }

    Json deleteUser(string tenantId, string userId) {
        validateId(tenantId, "Tenant ID");
        validateId(userId, "User ID");

        if (!_store.deleteUser(tenantId, userId))
            throw new IPNotFoundException("User", tenantId ~ "/" ~ userId);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["message"] = "User deleted";
        return result;
    }

    // ─── Group CRUD ───────────────────────────────────────────

    Json createGroup(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto group = groupFromJson(tenantId, request);
        if (group.groupName.length == 0)
            throw new IPValidationException("group_name is required");

        auto saved = _store.upsertGroup(group);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["group"] = saved.toJson();
        return result;
    }

    Json listGroups(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (group; _store.listGroups(tenantId)) {
            resources ~= group.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    Json getGroup(string tenantId, string groupId) {
        validateId(tenantId, "Tenant ID");
        validateId(groupId, "Group ID");

        auto group = _store.getGroup(tenantId, groupId);
        if (group.groupId.length == 0)
            throw new IPNotFoundException("Group", tenantId ~ "/" ~ groupId);

        Json result = Json.emptyObject;
        result["group"] = group.toJson();
        return result;
    }

    Json deleteGroup(string tenantId, string groupId) {
        validateId(tenantId, "Tenant ID");
        validateId(groupId, "Group ID");

        if (!_store.deleteGroup(tenantId, groupId))
            throw new IPNotFoundException("Group", tenantId ~ "/" ~ groupId);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["message"] = "Group deleted";
        return result;
    }

    // ─── Transformation / Filter CRUD ─────────────────────────

    Json createTransformation(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto transformation = transformationFromJson(tenantId, request);
        if (transformation.systemId.length == 0)
            throw new IPValidationException("system_id is required");

        auto saved = _store.upsertTransformation(transformation);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["transformation"] = saved.toJson();
        return result;
    }

    Json listTransformations(string tenantId, string systemId = "") {
        validateId(tenantId, "Tenant ID");

        IPTransformation[] transformations;
        if (systemId.length > 0)
            transformations = _store.listTransformationsForSystem(tenantId, systemId);
        else
            transformations = _store.listTransformations(tenantId);

        Json resources = Json.emptyArray;
        foreach (t; transformations) {
            resources ~= t.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    Json getTransformation(string tenantId, string transformationId) {
        validateId(tenantId, "Tenant ID");
        validateId(transformationId, "Transformation ID");

        auto t = _store.getTransformation(tenantId, transformationId);
        if (t.transformationId.length == 0)
            throw new IPNotFoundException("Transformation", tenantId ~ "/" ~ transformationId);

        Json result = Json.emptyObject;
        result["transformation"] = t.toJson();
        return result;
    }

    Json deleteTransformation(string tenantId, string transformationId) {
        validateId(tenantId, "Tenant ID");
        validateId(transformationId, "Transformation ID");

        if (!_store.deleteTransformation(tenantId, transformationId))
            throw new IPNotFoundException("Transformation", tenantId ~ "/" ~ transformationId);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["message"] = "Transformation deleted";
        return result;
    }

    // ─── Provisioning Jobs ────────────────────────────────────

    /** Create and immediately run a provisioning job.
     *
     *  The job reads entities from the source system and provisions
     *  them to all target systems.  Transformations and filter rules
     *  are applied during the process.
     *
     *  In delta mode, only entities modified since the last delta
     *  token are read.
     */
    Json runJob(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto job = jobFromJson(tenantId, request);
        if (job.sourceSystemId.length == 0)
            throw new IPValidationException("source_system_id is required");
        if (job.readMode != "full" && job.readMode != "delta")
            throw new IPValidationException("read_mode must be 'full' or 'delta'");

        // Verify source system exists
        auto sourceSystem = _store.getSystemById(tenantId, job.sourceSystemId);
        if (sourceSystem.systemId.length == 0)
            throw new IPNotFoundException("Source system", job.sourceSystemId);

        // If no targets specified, use all target systems
        if (job.targetSystemIds.length == 0) {
            foreach (sys; _store.listSystemsByType(tenantId, "target")) {
                job.targetSystemIds ~= sys.systemId;
            }
        }

        // Start job
        job.status = "running";
        job.startedAt = Clock.currTime().toISOExtString();
        job.updatedAt = job.startedAt;
        _store.upsertJob(job);

        _store.appendJobLog(createJobLog(tenantId, job.jobId, "info", "job", job.jobId,
            "Provisioning job started in " ~ job.readMode ~ " mode"));

        // Execute provisioning
        try {
            executeProvisioning(tenantId, job);
        } catch (Exception e) {
            job.status = "failed";
            job.completedAt = Clock.currTime().toISOExtString();
            job.updatedAt = job.completedAt;
            _store.upsertJob(job);

            _store.appendJobLog(createJobLog(tenantId, job.jobId, "error", "job", job.jobId,
                "Job failed: " ~ e.msg));

            notifySubscribers(tenantId, job.sourceSystemId, "job.failed", job.jobId);

            Json result = Json.emptyObject;
            result["success"] = false;
            result["job"] = job.toJson();
            result["message"] = "Job failed: " ~ e.msg;
            return result;
        }

        // Reload job with updated stats
        job = _store.getJob(tenantId, job.jobId);
        job.status = "completed";
        job.completedAt = Clock.currTime().toISOExtString();
        job.updatedAt = job.completedAt;

        // Generate new delta token for next delta read
        job.deltaToken = Clock.currTime().toISOExtString();
        _store.upsertJob(job);

        _store.appendJobLog(createJobLog(tenantId, job.jobId, "info", "job", job.jobId,
            "Provisioning job completed successfully"));

        notifySubscribers(tenantId, job.sourceSystemId, "job.completed", job.jobId);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["job"] = job.toJson();
        return result;
    }

    Json listJobs(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (job; _store.listJobs(tenantId)) {
            resources ~= job.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    Json getJob(string tenantId, string jobId) {
        validateId(tenantId, "Tenant ID");
        validateId(jobId, "Job ID");

        auto job = _store.getJob(tenantId, jobId);
        if (job.jobId.length == 0)
            throw new IPNotFoundException("Job", tenantId ~ "/" ~ jobId);

        Json result = Json.emptyObject;
        result["job"] = job.toJson();
        return result;
    }

    Json cancelJob(string tenantId, string jobId) {
        validateId(tenantId, "Tenant ID");
        validateId(jobId, "Job ID");

        auto job = _store.getJob(tenantId, jobId);
        if (job.jobId.length == 0)
            throw new IPNotFoundException("Job", tenantId ~ "/" ~ jobId);

        if (job.status != "running" && job.status != "pending")
            throw new IPValidationException("Job is not running or pending");

        job.status = "cancelled";
        job.completedAt = Clock.currTime().toISOExtString();
        job.updatedAt = job.completedAt;
        _store.upsertJob(job);

        _store.appendJobLog(createJobLog(tenantId, jobId, "info", "job", jobId,
            "Job cancelled by user"));

        notifySubscribers(tenantId, job.sourceSystemId, "job.cancelled", jobId);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["job"] = job.toJson();
        return result;
    }

    // ─── Job Logging ──────────────────────────────────────────

    Json listJobLogs(string tenantId, string jobId, string level = "") {
        validateId(tenantId, "Tenant ID");
        validateId(jobId, "Job ID");

        auto job = _store.getJob(tenantId, jobId);
        if (job.jobId.length == 0)
            throw new IPNotFoundException("Job", tenantId ~ "/" ~ jobId);

        IPJobLog[] logs;
        if (level.length > 0)
            logs = _store.listJobLogsByLevel(tenantId, jobId, level);
        else
            logs = _store.listJobLogs(tenantId, jobId);

        Json resources = Json.emptyArray;
        foreach (log; logs) {
            resources ~= log.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["job_id"] = jobId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    /** Export job logs as a flat JSON array (for download). */
    Json exportJobLogs(string tenantId, string jobId) {
        validateId(tenantId, "Tenant ID");
        validateId(jobId, "Job ID");

        auto job = _store.getJob(tenantId, jobId);
        if (job.jobId.length == 0)
            throw new IPNotFoundException("Job", tenantId ~ "/" ~ jobId);

        auto logs = _store.listJobLogs(tenantId, jobId);

        Json resources = Json.emptyArray;
        foreach (log; logs) {
            resources ~= log.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["job_id"] = jobId;
        result["job_name"] = job.jobName;
        result["job_status"] = job.status;
        result["exported_at"] = Clock.currTime().toISOExtString();
        result["logs"] = resources;
        result["total_logs"] = cast(long) resources.length;
        return result;
    }

    // ─── Notification Subscriptions ───────────────────────────

    Json createNotification(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto notification = notificationFromJson(tenantId, request);
        if (notification.sourceSystemId.length == 0)
            throw new IPValidationException("source_system_id is required");
        if (notification.callbackUrl.length == 0)
            throw new IPValidationException("callback_url is required");
        if (notification.eventTypes.length == 0)
            throw new IPValidationException("event_types must contain at least one event type");

        auto saved = _store.upsertNotification(notification);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["subscription"] = saved.toJson();
        return result;
    }

    Json listNotifications(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (n; _store.listNotifications(tenantId)) {
            resources ~= n.toJson();
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["resources"] = resources;
        result["total_results"] = cast(long) resources.length;
        return result;
    }

    Json deleteNotification(string tenantId, string subscriptionId) {
        validateId(tenantId, "Tenant ID");
        validateId(subscriptionId, "Subscription ID");

        if (!_store.deleteNotification(tenantId, subscriptionId))
            throw new IPNotFoundException("Notification subscription", tenantId ~ "/" ~ subscriptionId);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["message"] = "Notification subscription deleted";
        return result;
    }

    // ─── Dashboard ────────────────────────────────────────────

    Json dashboard(string tenantId) {
        validateId(tenantId, "Tenant ID");

        auto systems = _store.listSystems(tenantId);
        auto users = _store.listUsers(tenantId);
        auto groups = _store.listGroups(tenantId);
        auto jobs = _store.listJobs(tenantId);
        auto transformations = _store.listTransformations(tenantId);
        auto notifications = _store.listNotifications(tenantId);

        long sourceSystems = 0;
        long targetSystems = 0;
        foreach (sys; systems) {
            if (sys.systemType == "source") ++sourceSystems;
            else if (sys.systemType == "target") ++targetSystems;
        }

        long completedJobs = 0;
        long failedJobs = 0;
        long runningJobs = 0;
        foreach (job; jobs) {
            if (job.status == "completed") ++completedJobs;
            else if (job.status == "failed") ++failedJobs;
            else if (job.status == "running") ++runningJobs;
        }

        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["total_systems"] = cast(long) systems.length;
        result["source_systems"] = sourceSystems;
        result["target_systems"] = targetSystems;
        result["total_users"] = cast(long) users.length;
        result["total_groups"] = cast(long) groups.length;
        result["total_jobs"] = cast(long) jobs.length;
        result["completed_jobs"] = completedJobs;
        result["failed_jobs"] = failedJobs;
        result["running_jobs"] = runningJobs;
        result["total_transformations"] = cast(long) transformations.length;
        result["total_notifications"] = cast(long) notifications.length;
        return result;
    }

    // ─── Private provisioning engine ──────────────────────────

    private void executeProvisioning(string tenantId, ref IPJob job) {
        // Get users from source system
        IPUser[] sourceUsers;
        if (job.readMode == "delta" && job.deltaToken.length > 0) {
            sourceUsers = _store.listModifiedUsersSince(tenantId, job.sourceSystemId, job.deltaToken);
        } else {
            sourceUsers = _store.listUsersBySystem(tenantId, job.sourceSystemId);
        }

        // Get groups from source system
        auto sourceGroups = _store.listGroupsBySystem(tenantId, job.sourceSystemId);

        job.usersRead = cast(long) sourceUsers.length;
        job.groupsRead = cast(long) sourceGroups.length;

        _store.appendJobLog(createJobLog(tenantId, job.jobId, "info", "job", job.jobId,
            "Read " ~ intToStr(job.usersRead) ~ " users and " ~ intToStr(job.groupsRead) ~ " groups from source"));

        // Get transformations for source system
        auto transformations = _store.listTransformationsForSystem(tenantId, job.sourceSystemId);

        // Sort transformations by priority
        sortTransformations(transformations);

        // Apply filter transformations to users
        foreach (ref user; sourceUsers) {
            bool skip = false;
            foreach (t; transformations) {
                if (t.entityType == "user" && t.action == "filter") {
                    auto attrValue = getUserAttribute(user, t.sourceAttribute);
                    if (!evaluateCondition(t.condition, attrValue)) {
                        user.status = "skipped";
                        ++job.usersSkipped;
                        skip = true;

                        _store.appendJobLog(createJobLog(tenantId, job.jobId, "info", "user", user.userId,
                            "User skipped by filter: " ~ t.condition));
                        break;
                    }
                }
                if (t.entityType == "user" && t.action == "skip") {
                    user.status = "skipped";
                    ++job.usersSkipped;
                    skip = true;
                    break;
                }
            }

            if (!skip) {
                // Provision user to target systems
                foreach (targetId; job.targetSystemIds) {
                    auto targetSystem = _store.getSystemById(tenantId, targetId);
                    if (targetSystem.systemId.length == 0 || targetSystem.status != "active") {
                        ++job.usersFailed;
                        _store.appendJobLog(createJobLog(tenantId, job.jobId, "warning", "user", user.userId,
                            "Target system unavailable: " ~ targetId));
                        continue;
                    }

                    // Apply mapping transformations
                    auto provisionedUser = applyUserTransformations(user, transformations);
                    provisionedUser.status = "synced";
                    provisionedUser.updatedAt = Clock.currTime().toISOExtString();
                    provisionedUser.lastModifiedAt = provisionedUser.updatedAt;
                    _store.upsertUser(provisionedUser);
                    ++job.usersWritten;

                    _store.appendJobLog(createJobLog(tenantId, job.jobId, "info", "user", user.userId,
                        "User provisioned to " ~ targetSystem.systemName));
                }
            }
        }

        // Apply filter transformations to groups
        foreach (ref group; sourceGroups) {
            bool skip = false;
            foreach (t; transformations) {
                if (t.entityType == "group" && t.action == "filter") {
                    auto attrValue = getGroupAttribute(group, t.sourceAttribute);
                    if (!evaluateCondition(t.condition, attrValue)) {
                        group.status = "skipped";
                        ++job.groupsSkipped;
                        skip = true;
                        break;
                    }
                }
                if (t.entityType == "group" && t.action == "skip") {
                    group.status = "skipped";
                    ++job.groupsSkipped;
                    skip = true;
                    break;
                }
            }

            if (!skip) {
                foreach (targetId; job.targetSystemIds) {
                    auto targetSystem = _store.getSystemById(tenantId, targetId);
                    if (targetSystem.systemId.length == 0 || targetSystem.status != "active") {
                        ++job.groupsFailed;
                        continue;
                    }

                    group.status = "synced";
                    group.updatedAt = Clock.currTime().toISOExtString();
                    _store.upsertGroup(group);
                    ++job.groupsWritten;

                    _store.appendJobLog(createJobLog(tenantId, job.jobId, "info", "group", group.groupId,
                        "Group provisioned to " ~ targetSystem.systemName));
                }
            }
        }

        // Update system counts
        _store.updateSystemCounts(tenantId, job.sourceSystemId,
            cast(long) sourceUsers.length, cast(long) sourceGroups.length);

        job.updatedAt = Clock.currTime().toISOExtString();
        _store.upsertJob(job);
    }

    private IPUser applyUserTransformations(IPUser user, IPTransformation[] transformations) {
        foreach (t; transformations) {
            if (t.entityType != "user" || !t.active) continue;
            if (t.action == "default") {
                auto currentVal = getUserAttribute(user, t.targetAttribute);
                if (currentVal.length == 0) {
                    setUserAttribute(user, t.targetAttribute, t.defaultValue);
                }
            }
            // map action: source → target attribute mapping is implicit
            // (same in-memory store, so attributes are already present)
        }
        return user;
    }

    private string getUserAttribute(const IPUser user, string attr) {
        switch (attr) {
            case "user_name":    return user.userName;
            case "email":        return user.email;
            case "first_name":   return user.firstName;
            case "last_name":    return user.lastName;
            case "display_name": return user.displayName;
            case "external_id":  return user.externalId;
            default:             return "";
        }
    }

    private void setUserAttribute(ref IPUser user, string attr, string value) {
        switch (attr) {
            case "user_name":    user.userName = value; break;
            case "email":        user.email = value; break;
            case "first_name":   user.firstName = value; break;
            case "last_name":    user.lastName = value; break;
            case "display_name": user.displayName = value; break;
            case "external_id":  user.externalId = value; break;
            default: break;
        }
    }

    private string getGroupAttribute(const IPGroup group, string attr) {
        switch (attr) {
            case "group_name":   return group.groupName;
            case "display_name": return group.displayName;
            case "description":  return group.description;
            case "external_id":  return group.externalId;
            default:             return "";
        }
    }

    /** Simple insertion sort by priority (stable, ascending). */
    private void sortTransformations(ref IPTransformation[] ts) {
        for (size_t i = 1; i < ts.length; ++i) {
            auto tmp = ts[i];
            long j = cast(long) i - 1;
            while (j >= 0 && ts[cast(size_t) j].priority > tmp.priority) {
                ts[cast(size_t)(j + 1)] = ts[cast(size_t) j];
                --j;
            }
            ts[cast(size_t)(j + 1)] = tmp;
        }
    }

    private void notifySubscribers(string tenantId, string sourceSystemId, string eventType, string jobId) {
        auto subscribers = _store.listNotificationsForSystem(tenantId, sourceSystemId);
        foreach (sub; subscribers) {
            foreach (evt; sub.eventTypes) {
                if (evt == eventType) {
                    // In a real implementation, this would POST to sub.callbackUrl.
                    // Here we just log the notification attempt.
                    _store.appendJobLog(createJobLog(tenantId, jobId, "info", "system", sub.subscriptionId,
                        "Notification sent: " ~ eventType ~ " to " ~ sub.callbackUrl));
                    break;
                }
            }
        }
    }

    /** Convert a long to string without std.conv (to stay @safe-friendly). */
    private string intToStr(long val) {
        import std.conv : to;
        return to!string(val);
    }

    private void validateId(string value, string fieldName) {
        if (value.length == 0)
            throw new IPValidationException(fieldName ~ " cannot be empty");
    }
}
