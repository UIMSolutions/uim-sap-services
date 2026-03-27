/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

  this(PDMConfig config) {
    super(config);

    _store = new PDMStore;

    // Ensure default tenant exists
    auto cfg = cast(PDMConfig)_config;
    if (cfg.defaultTenantId == NULLUUID) {
      PDMTenant t = new PDMTenant;
      t.tenantId = cfg.defaultTenantId;
      t.name = "Default Tenant";
      t.createdAt = Clock.currTime();
      t.updatedAt = t.createdAt;
      _store.upsertTenant(t);
    }
  }

  override Json health() {
    return super.health()
      .set("subjects", cast(long)_store.totalSubjectCount())
      .set("requests", cast(long)_store.totalRequestCount());
  }

  override Json ready() {
    return super.ready()
      .set("subjects", cast(long)_store.totalSubjectCount());
  }

  // ══════════════════════════════════════
  //  Tenant Management
  // ══════════════════════════════════════

  Json createTenant(Json req) {
    UUID tenantId = randomUUID(); // generateTenantId();
    PDMTenant t = PDMTenant(tenantId, req);
    _store.upsertTenant(t);
    return t.toJson();
  }

  Json getTenant(UUID tenantId) {
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
    foreach (ref t; tenants)
      arr ~= t.toJson();

    return Json.emptyObject
      .set("tenants", arr)
      .set("total", cast(long)tenants.length);
  }

  // ══════════════════════════════════════
  //  Data Subject Identification
  // ══════════════════════════════════════

  Json registerSubject(UUID tenantId, Json req) {
    ensureTenant(tenantId);

    PDMConfig cfg = cast(PDMConfig)_config;
    if (_store.subjectCount(tenantId) >= cfg.maxSubjectsPerTenant)
      throw new PDMQuotaExceededException("subjects", cfg.maxSubjectsPerTenant);

    UUID subjectId = randomUUID(); // generateSubjectId();
    PDMDataSubject s = PDMDataSubject(subjectId, tenantId, req);
    _store.upsertSubject(s);
    return s.toJson();
  }

  Json getSubject(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);
    return _store.getSubject(tenantId, subjectId).toJson();
  }

  Json listSubjects(UUID tenantId) {
    ensureTenant(tenantId);
    auto subjects = _store.listSubjects(tenantId);
    Json arr = Json.emptyArray;
    foreach (ref s; subjects)
      arr ~= s.toJson();

    return Json.emptyObject
      .set("subjects", arr)
      .set("total", cast(long)subjects.length);
  }

  /// Search subjects by term (name, email, company, external ID)
  Json searchSubjects(UUID tenantId, string term) {
    ensureTenant(tenantId);
    auto subjects = _store.searchSubjects(tenantId, term);
    auto arr = subjects.map!(s => s.toJson).array;

    return Json.emptyObject
      .set("subjects", arr)
      .set("total", cast(long)subjects.length)
      .set("search_term", term);
  }

  /// Search subjects by type (private or corporate)
  Json searchSubjectsByType(UUID tenantId, string typeStr) {
    ensureTenant(tenantId);
    PDMSubjectType st = parseSubjectTypeStr(typeStr);
    auto subjects = _store.searchSubjectsByType(tenantId, st);
    auto arr = subjects.map!(s => s.toJson).array;

    return Json.emptyObject
      .set("subjects", arr)
      .set("total", cast(long)subjects.length)
      .set("subject_type", typeStr);
  }

  Json updateSubject(UUID tenantId, UUID subjectId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);

    PDMDataSubject s = _store.getSubject(tenantId, subjectId);
    if ("first_name" in req && req["first_name"].isString)
      s.firstName = req["first_name"].getString;
    if ("last_name" in req && req["last_name"].isString)
      s.lastName = req["last_name"].getString;
    if ("display_name" in req && req["display_name"].isString)
      s.displayName = req["display_name"].getString;
    if ("email" in req && req["email"].isString)
      s.email = req["email"].getString;
    if ("phone" in req && req["phone"].isString)
      s.phone = req["phone"].getString;
    if ("company_name" in req && req["company_name"].isString)
      s.companyName = req["company_name"].getString;
    if ("department" in req && req["department"].isString)
      s.department = req["department"].getString;
    s.updatedAt = Clock.currTime();
    _store.upsertSubject(s);
    return s.toJson();
  }

  Json deleteSubject(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);

    _store.removeRecordsBySubject(tenantId, subjectId);
    _store.removeSubject(tenantId, subjectId);

    return Json.emptyObject
      .set("status", "deleted")
      .set("subject_id", subjectId);
  }

  // ══════════════════════════════════════
  //  Personal Data Records (Inform)
  // ══════════════════════════════════════

  Json addRecord(UUID tenantId, UUID subjectId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);

    PDMConfig cfg = cast(PDMConfig)_config;
    if (_store.recordCountBySubject(tenantId, subjectId) >= cfg.maxRecordsPerSubject)
      throw new PDMQuotaExceededException("records per subject", cfg.maxRecordsPerSubject);

    UUID recordId = randomUUID; // generateRecordId();
    PDMPersonalDataRecord r = recordFromJson(recordId, subjectId, tenantId, req);
    _store.upsertRecord(r);
    return r.toJson();
  }

  /// Get all personal data records for a data subject (inform)
  Json getSubjectRecords(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId.toString);

    auto records = _store.listRecordsBySubject(tenantId, subjectId);
    auto arr = records.map!(r => r.toJson).array;

    return Json.emptyObject
      .set("subject_id", subjectId)
      .set("records", arr)
      .set("total", cast(long)records.length);
  }

  /// Generate a personal data report for a subject (for sending via email)
  Json generateDataReport(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId.toString);

    auto subject = _store.getSubject(tenantId, subjectId);
    auto records = _store.listRecordsBySubject(tenantId, subjectId);
    auto usages = _store.listUsagesBySubject(tenantId, subjectId);

    auto recArr = records.map!(r => r.toJson).array;
    auto usageArr = usages.map!(u => u.toJson).array;

    return Json.emptyObject
      .set("report_type", "personal_data_report")
      .set("generated_at", Clock.currTime().toISOExtString())
      .set("subject", subject.toJson())
      .set("personal_data_records", recArr)
      .set("data_usages", usageArr)
      .set("total_records", cast(long)records.length)
      .set("total_usages", cast(long)usages.length);
  }

  Json deleteRecord(UUID tenantId, UUID recordId) {
    ensureTenant(tenantId);
    if (!_store.hasRecord(tenantId, recordId))
      throw new PDMNotFoundException("PersonalDataRecord", recordId.toString);
    _store.removeRecord(tenantId, recordId);

    return Json.emptyObject
      .set("status", "deleted")
      .set("record_id", recordId);
  }

  // ══════════════════════════════════════
  //  Data Subject Requests (Manage)
  // ══════════════════════════════════════

  Json createRequest(UUID tenantId, UUID subjectId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId.toString);

    PDMConfig cfg = cast(PDMConfig)_config;
    if (_store.requestCount(tenantId) >= cfg.maxRequestsPerTenant)
      throw new PDMQuotaExceededException("requests", cfg.maxRequestsPerTenant);

    UUID requestId = randomUUID(); // generateRequestId();
    PDMDataRequest r = PDMDataRequest(requestId, subjectId, tenantId, req);
    _store.upsertRequest(r);
    return r.toJson();
  }

  Json getRequest(UUID tenantId, UUID requestId) {
    ensureTenant(tenantId);
    if (!_store.hasRequest(tenantId, requestId))
      throw new PDMNotFoundException("DataRequest", requestId.toString());
    return _store.getRequest(tenantId, requestId).toJson();
  }

  Json listRequests(UUID tenantId) {
    ensureTenant(tenantId);
    auto requests = _store.listRequests(tenantId);
    Json arr = requests.map!(r => r.toJson).array;

    return Json.emptyObject
      .set("requests", arr)
      .set("total", cast(long)requests.length);
  }

  Json listRequestsBySubject(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    auto requests = _store.listRequestsBySubject(tenantId, subjectId);
    Json arr = requests.map!(r => r.toJson).array;

    return Json.emptyObject
      .set("subject_id", subjectId)
      .set("requests", arr)
      .set("total", cast(long)requests.length);
  }

  Json listRequestsByStatus(UUID tenantId, string statusStr) {
    ensureTenant(tenantId);
    PDMRequestStatus st = parseRequestStatusStr(statusStr);
    auto requests = _store.listRequestsByStatus(tenantId, st);
    Json arr = requests.map!(r => r.toJson).array;

    return Json.emptyObject
      .set("status_filter", statusStr)
      .set("requests", arr)
      .set("total", cast(long)requests.length);
  }

  /// Submit a draft request for processing
  Json submitRequest(UUID tenantId, UUID requestId) {
    ensureTenant(tenantId);
    if (!_store.hasRequest(tenantId, requestId))
      throw new PDMNotFoundException("DataRequest", requestId.toString);

    PDMDataRequest r = _store.getRequest(tenantId, requestId);
    if (r.status != PDMRequestStatus.draft)
      throw new PDMValidationException("Only draft requests can be submitted");

    r.status = PDMRequestStatus.submitted;
    r.updatedAt = Clock.currTime();
    _store.upsertRequest(r);
    return r.toJson();
  }

  /// Begin processing a submitted request
  Json processRequest(UUID tenantId, UUID requestId) {
    ensureTenant(tenantId);
    if (!_store.hasRequest(tenantId, requestId))
      throw new PDMNotFoundException("DataRequest", requestId.toString);

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
  Json completeRequest(UUID tenantId, UUID requestId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasRequest(tenantId, requestId))
      throw new PDMNotFoundException("DataRequest", requestId.toString());

    PDMDataRequest r = _store.getRequest(tenantId, requestId);
    if (r.status != PDMRequestStatus.processing)
      throw new PDMValidationException("Only processing requests can be completed");

    r.status = PDMRequestStatus.completed;
    r.completedAt = Clock.currTime();
    r.updatedAt = r.completedAt;
    if ("resolution" in req && req["resolution"].isString)
      r.resolution = req["resolution"].getString;
    _store.upsertRequest(r);
    return r.toJson();
  }

  /// Reject a request
  Json rejectRequest(UUID tenantId, UUID requestId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasRequest(tenantId, requestId))
      throw new PDMNotFoundException("DataRequest", requestId.toString());

    PDMDataRequest r = _store.getRequest(tenantId, requestId);
    if (r.status == PDMRequestStatus.completed || r.status == PDMRequestStatus.cancelled)
      throw new PDMValidationException("Cannot reject a completed or cancelled request");

    r.status = PDMRequestStatus.rejected;
    r.updatedAt = Clock.currTime();
    if ("resolution" in req && req["resolution"].isString)
      r.resolution = req["resolution"].getString;
    _store.upsertRequest(r);
    return r.toJson();
  }

  /// Cancel a request
  Json cancelRequest(UUID tenantId, UUID requestId) {
    ensureTenant(tenantId);
    if (!_store.hasRequest(tenantId, requestId))
      throw new PDMNotFoundException("DataRequest", requestId.toString());

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

  Json sendNotification(UUID tenantId, UUID subjectId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);

    UUID notificationId = UUID(generateNotificationId());
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
  Json sendDataReport(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);

    auto subject = _store.getSubject(tenantId, subjectId);
    auto report = generateDataReport(tenantId, subjectId);

    UUID notificationId = UUID(generateNotificationId());
    PDMNotification n = new PDMNotification;
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

  Json listNotifications(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    auto notifications = _store.listNotificationsBySubject(tenantId, subjectId);
    auto arr = notifications.map!(notif => notif.toJson()).array;

    return Json.emptyObject
      .set("notifications", arr)
      .set("total", cast(long)notifications.length);
  }

  // ══════════════════════════════════════
  //  Data Usage Tracking
  // ══════════════════════════════════════

  Json addUsage(UUID tenantId, UUID subjectId, Json req) {
    ensureTenant(tenantId);
    if (!_store.hasSubject(tenantId, subjectId))
      throw new PDMNotFoundException("DataSubject", subjectId);

    UUID usageId = randomUUID(); // generateUsageId();
    PDMDataUsage u = PDMDataUsage(usageId, subjectId, tenantId, req);
    _store.upsertUsage(u);
    return u.toJson();
  }

  Json listUsages(UUID tenantId, UUID subjectId) {
    ensureTenant(tenantId);
    auto usages = _store.listUsagesBySubject(tenantId, subjectId);
    auto arr = usages.map!(u => u.toJson()).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("subject_id", subjectId)
      .set("usages", arr)
      .set("total", cast(long)usages.length);
  }

  // ══════════════════════════════════════
  //  Private Helpers
  // ══════════════════════════════════════

  private void ensureTenant(UUID tenantId) {
    PDMConfig cfg = cast(PDMConfig)_config;
    if (cfg.multitenancy && !_store.hasTenant(tenantId)) {
      throw new PDMNotFoundException("Tenant", tenantId);
    }
  }

  private static PDMSubjectType parseSubjectTypeStr(string s) {
    switch (s) {
    case "private":
      return PDMSubjectType.privatePerson;
    case "corporate":
      return PDMSubjectType.corporateCustomer;
    case "employee":
      return PDMSubjectType.employee;
    case "business_partner":
      return PDMSubjectType.businessPartner;
    default:
      return PDMSubjectType.privatePerson;
    }
  }

  private static PDMRequestStatus parseRequestStatusStr(string s) {
    switch (s) {
    case "draft":
      return PDMRequestStatus.draft;
    case "submitted":
      return PDMRequestStatus.submitted;
    case "processing":
      return PDMRequestStatus.processing;
    case "completed":
      return PDMRequestStatus.completed;
    case "rejected":
      return PDMRequestStatus.rejected;
    case "cancelled":
      return PDMRequestStatus.cancelled;
    default:
      return PDMRequestStatus.draft;
    }
  }
}
