module uim.sap.pdm.service;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/**
 * Main service class for SAP Personal Data Manager.
 *
 * Manages data subject identification, personal data records,
 * data subject requests (GDPR Art. 15-22), notifications,
 * data usage tracking, and multitenancy.
 */
class PDMService : SAPService {
    mixin(SAPServiceTemplate!PDMService);

    private PDMStore _store;
    private PDMConfig _config;

    this(PDMConfig config) {
        super(config);
        _config = config;
        _store = new PDMStore;

        // Ensure default tenant exists
        if (_config.defaultTenantId.length > 0) {
            PDMTenant t;
            t.tenantId = _config.defaultTenantId;
            t.name = "Default Tenant";
            t.createdAt = Clock.currTime();
            t.updatedAt = t.createdAt;
            _store.upsertTenant(t);
        }
    }

    @property PDMConfig config() { return _config; }

    override Json health() {
        Json info = super.health();
        info["subjects"] = cast(long) _store.totalSubjectCount();
        info["requests"] = cast(long) _store.totalRequestCount();
        return info;
    }

    override Json ready() {
        Json info = super.ready();
        info["subjects"] = cast(long) _store.totalSubjectCount();
        return info;
    }

    // ══════════════════════════════════════
    //  Tenant Management
    // ══════════════════════════════════════

    Json createTenant(Json req) {
        string tenantId = generateTenantId();
        PDMTenant t = tenantFromJson(tenantId, req);
        _store.upsertTenant(t);
        return t.toJson();
    }

    Json getTenant(string tenantId) {
        if (!_store.hasTenant(tenantId))
            throw new PDMNotFoundException("Tenant", tenantId);
        auto t = _store.getTenant(tenantId);
        t.subjectCount = _store.subjectCount(tenantId);
        t.requestCount = _store.requestCount(tenantId);
        return t.toJson();
    }

    Json listTenants() {
        auto tenants = _store.listTenants();
        Json arr = Json.emptyArray;
        foreach (ref t; tenants) arr ~= t.toJson();
        Json result = Json.emptyObject;
        result["tenants"] = arr;
        result["total"] = cast(long) tenants.length;
        return result;
    }

    // ══════════════════════════════════════
    //  Data Subject Identification
    // ══════════════════════════════════════

    Json registerSubject(string tenantId, Json req) {
        ensureTenant(tenantId);
        if (_store.subjectCount(tenantId) >= _config.maxSubjectsPerTenant)
            throw new PDMQuotaExceededException("subjects", _config.maxSubjectsPerTenant);

        string subjectId = generateSubjectId();
        PDMDataSubject s = subjectFromJson(subjectId, tenantId, req);
        _store.upsertSubject(s);
        return s.toJson();
    }

    Json getSubject(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);
        return _store.getSubject(tenantId, subjectId).toJson();
    }

    Json listSubjects(string tenantId) {
        ensureTenant(tenantId);
        auto subjects = _store.listSubjects(tenantId);
        Json arr = Json.emptyArray;
        foreach (ref s; subjects) arr ~= s.toJson();
        Json result = Json.emptyObject;
        result["subjects"] = arr;
        result["total"] = cast(long) subjects.length;
        return result;
    }

    /// Search subjects by term (name, email, company, external ID)
    Json searchSubjects(string tenantId, string term) {
        ensureTenant(tenantId);
        auto subjects = _store.searchSubjects(tenantId, term);
        Json arr = Json.emptyArray;
        foreach (ref s; subjects) arr ~= s.toJson();
        Json result = Json.emptyObject;
        result["subjects"] = arr;
        result["total"] = cast(long) subjects.length;
        result["search_term"] = term;
        return result;
    }

    /// Search subjects by type (private or corporate)
    Json searchSubjectsByType(string tenantId, string typeStr) {
        ensureTenant(tenantId);
        PDMSubjectType st = parseSubjectTypeStr(typeStr);
        auto subjects = _store.searchSubjectsByType(tenantId, st);
        Json arr = Json.emptyArray;
        foreach (ref s; subjects) arr ~= s.toJson();
        Json result = Json.emptyObject;
        result["subjects"] = arr;
        result["total"] = cast(long) subjects.length;
        result["subject_type"] = typeStr;
        return result;
    }

    Json updateSubject(string tenantId, string subjectId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        PDMDataSubject s = _store.getSubject(tenantId, subjectId);
        if ("first_name" in req && req["first_name"].isString)
            s.firstName = req["first_name"].get!string;
        if ("last_name" in req && req["last_name"].isString)
            s.lastName = req["last_name"].get!string;
        if ("display_name" in req && req["display_name"].isString)
            s.displayName = req["display_name"].get!string;
        if ("email" in req && req["email"].isString)
            s.email = req["email"].get!string;
        if ("phone" in req && req["phone"].isString)
            s.phone = req["phone"].get!string;
        if ("company_name" in req && req["company_name"].isString)
            s.companyName = req["company_name"].get!string;
        if ("department" in req && req["department"].isString)
            s.department = req["department"].get!string;
        s.updatedAt = Clock.currTime();
        _store.upsertSubject(s);
        return s.toJson();
    }

    Json deleteSubject(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        _store.removeRecordsBySubject(tenantId, subjectId);
        _store.removeSubject(tenantId, subjectId);

        Json result = Json.emptyObject;
        result["status"] = "deleted";
        result["subject_id"] = subjectId;
        return result;
    }

    // ══════════════════════════════════════
    //  Personal Data Records (Inform)
    // ══════════════════════════════════════

    Json addRecord(string tenantId, string subjectId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);
        if (_store.recordCountBySubject(tenantId, subjectId) >= _config.maxRecordsPerSubject)
            throw new PDMQuotaExceededException("records per subject", _config.maxRecordsPerSubject);

        string recordId = generateRecordId();
        PDMPersonalDataRecord r = recordFromJson(recordId, subjectId, tenantId, req);
        _store.upsertRecord(r);
        return r.toJson();
    }

    /// Get all personal data records for a data subject (inform)
    Json getSubjectRecords(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        auto records = _store.listRecordsBySubject(tenantId, subjectId);
        Json arr = Json.emptyArray;
        foreach (ref r; records) arr ~= r.toJson();
        Json result = Json.emptyObject;
        result["subject_id"] = subjectId;
        result["records"] = arr;
        result["total"] = cast(long) records.length;
        return result;
    }

    /// Generate a personal data report for a subject (for sending via email)
    Json generateDataReport(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        auto subject = _store.getSubject(tenantId, subjectId);
        auto records = _store.listRecordsBySubject(tenantId, subjectId);
        auto usages = _store.listUsagesBySubject(tenantId, subjectId);

        Json recArr = Json.emptyArray;
        foreach (ref r; records) recArr ~= r.toJson();
        Json usageArr = Json.emptyArray;
        foreach (ref u; usages) usageArr ~= u.toJson();

        Json report = Json.emptyObject;
        report["report_type"] = "personal_data_report";
        report["generated_at"] = Clock.currTime().toISOExtString();
        report["subject"] = subject.toJson();
        report["personal_data_records"] = recArr;
        report["data_usages"] = usageArr;
        report["total_records"] = cast(long) records.length;
        report["total_usages"] = cast(long) usages.length;
        return report;
    }

    Json deleteRecord(string tenantId, string recordId) {
        ensureTenant(tenantId);
        if (!_store.hasRecord(tenantId, recordId))
            throw new PDMNotFoundException("PersonalDataRecord", recordId);
        _store.removeRecord(tenantId, recordId);
        Json result = Json.emptyObject;
        result["status"] = "deleted";
        result["record_id"] = recordId;
        return result;
    }

    // ══════════════════════════════════════
    //  Data Subject Requests (Manage)
    // ══════════════════════════════════════

    Json createRequest(string tenantId, string subjectId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);
        if (_store.requestCount(tenantId) >= _config.maxRequestsPerTenant)
            throw new PDMQuotaExceededException("requests", _config.maxRequestsPerTenant);

        string requestId = generateRequestId();
        PDMDataRequest r = requestFromJson(requestId, subjectId, tenantId, req);
        _store.upsertRequest(r);
        return r.toJson();
    }

    Json getRequest(string tenantId, string requestId) {
        ensureTenant(tenantId);
        if (!_store.hasRequest(tenantId, requestId))
            throw new PDMNotFoundException("DataRequest", requestId);
        return _store.getRequest(tenantId, requestId).toJson();
    }

    Json listRequests(string tenantId) {
        ensureTenant(tenantId);
        auto requests = _store.listRequests(tenantId);
        Json arr = Json.emptyArray;
        foreach (ref r; requests) arr ~= r.toJson();
        Json result = Json.emptyObject;
        result["requests"] = arr;
        result["total"] = cast(long) requests.length;
        return result;
    }

    Json listRequestsBySubject(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        auto requests = _store.listRequestsBySubject(tenantId, subjectId);
        Json arr = Json.emptyArray;
        foreach (ref r; requests) arr ~= r.toJson();
        Json result = Json.emptyObject;
        result["subject_id"] = subjectId;
        result["requests"] = arr;
        result["total"] = cast(long) requests.length;
        return result;
    }

    Json listRequestsByStatus(string tenantId, string statusStr) {
        ensureTenant(tenantId);
        PDMRequestStatus st = parseRequestStatusStr(statusStr);
        auto requests = _store.listRequestsByStatus(tenantId, st);
        Json arr = Json.emptyArray;
        foreach (ref r; requests) arr ~= r.toJson();
        Json result = Json.emptyObject;
        result["status_filter"] = statusStr;
        result["requests"] = arr;
        result["total"] = cast(long) requests.length;
        return result;
    }

    /// Submit a draft request for processing
    Json submitRequest(string tenantId, string requestId) {
        ensureTenant(tenantId);
        if (!_store.hasRequest(tenantId, requestId))
            throw new PDMNotFoundException("DataRequest", requestId);

        PDMDataRequest r = _store.getRequest(tenantId, requestId);
        if (r.status != PDMRequestStatus.draft)
            throw new PDMValidationException("Only draft requests can be submitted");

        r.status = PDMRequestStatus.submitted;
        r.updatedAt = Clock.currTime();
        _store.upsertRequest(r);
        return r.toJson();
    }

    /// Begin processing a submitted request
    Json processRequest(string tenantId, string requestId) {
        ensureTenant(tenantId);
        if (!_store.hasRequest(tenantId, requestId))
            throw new PDMNotFoundException("DataRequest", requestId);

        PDMDataRequest r = _store.getRequest(tenantId, requestId);
        if (r.status != PDMRequestStatus.submitted)
            throw new PDMValidationException("Only submitted requests can be processed");

        r.status = PDMRequestStatus.processing;
        r.updatedAt = Clock.currTime();
        _store.upsertRequest(r);

        // For erasure requests, automatically delete records
        if (r.requestType == PDMRequestType.erasure) {
            _store.removeRecordsBySubject(tenantId, r.subjectId);
        }

        return r.toJson();
    }

    /// Complete a request
    Json completeRequest(string tenantId, string requestId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasRequest(tenantId, requestId))
            throw new PDMNotFoundException("DataRequest", requestId);

        PDMDataRequest r = _store.getRequest(tenantId, requestId);
        if (r.status != PDMRequestStatus.processing)
            throw new PDMValidationException("Only processing requests can be completed");

        r.status = PDMRequestStatus.completed;
        r.completedAt = Clock.currTime();
        r.updatedAt = r.completedAt;
        if ("resolution" in req && req["resolution"].isString)
            r.resolution = req["resolution"].get!string;
        _store.upsertRequest(r);
        return r.toJson();
    }

    /// Reject a request
    Json rejectRequest(string tenantId, string requestId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasRequest(tenantId, requestId))
            throw new PDMNotFoundException("DataRequest", requestId);

        PDMDataRequest r = _store.getRequest(tenantId, requestId);
        if (r.status == PDMRequestStatus.completed || r.status == PDMRequestStatus.cancelled)
            throw new PDMValidationException("Cannot reject a completed or cancelled request");

        r.status = PDMRequestStatus.rejected;
        r.updatedAt = Clock.currTime();
        if ("resolution" in req && req["resolution"].isString)
            r.resolution = req["resolution"].get!string;
        _store.upsertRequest(r);
        return r.toJson();
    }

    /// Cancel a request
    Json cancelRequest(string tenantId, string requestId) {
        ensureTenant(tenantId);
        if (!_store.hasRequest(tenantId, requestId))
            throw new PDMNotFoundException("DataRequest", requestId);

        PDMDataRequest r = _store.getRequest(tenantId, requestId);
        if (r.status == PDMRequestStatus.completed)
            throw new PDMValidationException("Cannot cancel a completed request");

        r.status = PDMRequestStatus.cancelled;
        r.updatedAt = Clock.currTime();
        _store.upsertRequest(r);
        return r.toJson();
    }

    // ══════════════════════════════════════
    //  Notifications (Inform via email)
    // ══════════════════════════════════════

    Json sendNotification(string tenantId, string subjectId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        string notificationId = generateNotificationId();
        PDMNotification n = notificationFromJson(notificationId, subjectId, tenantId, req);

        // If no recipient, use the subject's email
        if (n.recipient.length == 0) {
            auto subject = _store.getSubject(tenantId, subjectId);
            n.recipient = subject.email;
        }

        if (n.recipient.length == 0)
            throw new PDMValidationException("No recipient email available");

        // Simulate sending
        n.status = PDMNotificationStatus.sent;
        n.sentAt = Clock.currTime();
        _store.storeNotification(n);
        return n.toJson();
    }

    /// Send a full data report to the subject via email
    Json sendDataReport(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        auto subject = _store.getSubject(tenantId, subjectId);
        auto report = generateDataReport(tenantId, subjectId);

        string notificationId = generateNotificationId();
        PDMNotification n;
        n.notificationId = notificationId;
        n.subjectId = subjectId;
        n.tenantId = tenantId;
        n.channel = PDMNotificationChannel.email;
        n.recipient = subject.email;
        n.subject = "Your Personal Data Report";
        n.body_ = "Please find attached your personal data report.";
        n.createdAt = Clock.currTime();
        n.status = PDMNotificationStatus.sent;
        n.sentAt = n.createdAt;
        _store.storeNotification(n);

        Json result = Json.emptyObject;
        result["notification"] = n.toJson();
        result["report"] = report;
        return result;
    }

    Json listNotifications(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        auto notifications = _store.listNotificationsBySubject(tenantId, subjectId);
        Json arr = Json.emptyArray;
        foreach (ref n; notifications) arr ~= n.toJson();
        Json result = Json.emptyObject;
        result["notifications"] = arr;
        result["total"] = cast(long) notifications.length;
        return result;
    }

    // ══════════════════════════════════════
    //  Data Usage Tracking
    // ══════════════════════════════════════

    Json addUsage(string tenantId, string subjectId, Json req) {
        ensureTenant(tenantId);
        if (!_store.hasSubject(tenantId, subjectId))
            throw new PDMNotFoundException("DataSubject", subjectId);

        string usageId = generateUsageId();
        PDMDataUsage u = usageFromJson(usageId, subjectId, tenantId, req);
        _store.upsertUsage(u);
        return u.toJson();
    }

    Json listUsages(string tenantId, string subjectId) {
        ensureTenant(tenantId);
        auto usages = _store.listUsagesBySubject(tenantId, subjectId);
        Json arr = Json.emptyArray;
        foreach (ref u; usages) arr ~= u.toJson();
        Json result = Json.emptyObject;
        result["usages"] = arr;
        result["total"] = cast(long) usages.length;
        return result;
    }

    // ══════════════════════════════════════
    //  Private Helpers
    // ══════════════════════════════════════

    private void ensureTenant(string tenantId) {
        if (_config.multitenancy && !_store.hasTenant(tenantId))
            throw new PDMNotFoundException("Tenant", tenantId);
    }

    private static PDMSubjectType parseSubjectTypeStr(string s) {
        switch (s) {
            case "private": return PDMSubjectType.privatePerson;
            case "corporate": return PDMSubjectType.corporateCustomer;
            case "employee": return PDMSubjectType.employee;
            case "business_partner": return PDMSubjectType.businessPartner;
            default: return PDMSubjectType.privatePerson;
        }
    }

    private static PDMRequestStatus parseRequestStatusStr(string s) {
        switch (s) {
            case "draft": return PDMRequestStatus.draft;
            case "submitted": return PDMRequestStatus.submitted;
            case "processing": return PDMRequestStatus.processing;
            case "completed": return PDMRequestStatus.completed;
            case "rejected": return PDMRequestStatus.rejected;
            case "cancelled": return PDMRequestStatus.cancelled;
            default: return PDMRequestStatus.draft;
        }
    }
}
