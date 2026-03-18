/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.models.subject;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Data subject — an identified or identifiable natural/legal person
class PDMDataSubject : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!PDMDataSubject);

    string subjectId;
    PDMSubjectType subjectType = PDMSubjectType.privatePerson;
    PDMSubjectStatus status = PDMSubjectStatus.active;

    // Identification
    string firstName;
    string lastName;
    string displayName;
    string email;
    string phone;

    // Corporate fields
    string companyName;
    UUID companyId;
    string department;

    // External references
    UUID externalId;       // ID in the source system
    string sourceSystem;     // originating application/service

    string[string] metadata;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
      auto json = super.toJson()
        .set("subject_id", subjectId)
        .set("subject_type", cast(string) subjectType)
        .set("status", cast(string) status)
        .set("first_name", firstName)
        .set("last_name", lastName)
        .set("display_name", displayName)
        .set("email", email)
        .set("phone", phone)
        .set("company_name", companyName)
        .set("company_id", companyId.toString())
        .set("department", department)
        .set("external_id", externalId)
        .set("source_system", sourceSystem)
        if (metadata.length > 0) {
          Json meta = Json.emptyObject;
          foreach (k, v; metadata) meta[k] = v;
          json["metadata"] = meta;
        }

        return json;
    }

    static PDMDataSubject opCall(string subjectId, string tenantId, Json req) {
    PDMDataSubject s = new PDMDataSubject(req);
    s.subjectId = subjectId;
    s.tenantId = UUID(tenantId);
    s.createdAt = Clock.currTime();
    s.updatedAt = s.createdAt;

    if ("subject_type" in req && req["subject_type"].isString)
        s.subjectType = parseSubjectType(req["subject_type"].get!string);
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
    if ("company_id" in req && req["company_id"].isString)
        s.companyId = req["company_id"].get!string;
    if ("department" in req && req["department"].isString)
        s.department = req["department"].get!string;
    if ("external_id" in req && req["external_id"].isString)
        s.externalId = req["external_id"].get!string;
    if ("source_system" in req && req["source_system"].isString)
        s.sourceSystem = req["source_system"].get!string;
    if ("metadata" in req && req["metadata"].type == Json.Type.object) {
        foreach (string k, v; req["metadata"])
            if (v.isString) s.metadata[k] = v.get!string;
    }

    if (s.displayName.length == 0 && s.firstName.length > 0)
        s.displayName = s.firstName ~ " " ~ s.lastName;

    return s;
}

}


private PDMSubjectType parseSubjectType(string s) {
    switch (s) {
        case "private": return PDMSubjectType.privatePerson;
        case "corporate": return PDMSubjectType.corporateCustomer;
        case "employee": return PDMSubjectType.employee;
        case "business_partner": return PDMSubjectType.businessPartner;
        default: return PDMSubjectType.privatePerson;
    }
}
