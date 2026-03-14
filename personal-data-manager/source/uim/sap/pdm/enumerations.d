/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.enumerations;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Type of data subject
enum PDMSubjectType : string {
  privatePerson = "private",
  corporateCustomer = "corporate",
  employee = "employee",
  businessPartner = "business_partner",
}

/// Category of personal data
enum PDMDataCategory : string {
  identification = "identification",
  contact = "contact",
  financial = "financial",
  health = "health",
  behavioral = "behavioral",
  technical = "technical",
  location = "location",
  biometric = "biometric",
  genetic = "genetic",
}

/// Purpose for processing personal data
enum PDMProcessingPurpose : string {
  contractual = "contractual",
  legal = "legal",
  consent = "consent",
  legitimateInterest = "legitimate_interest",
  vitalInterest = "vital_interest",
  publicInterest = "public_interest",
}

/// Type of data subject request (GDPR Article 15-22)
enum PDMRequestType : string {
  access = "access", // Art. 15: Right of access
  rectification = "rectification", // Art. 16: Right to rectification
  erasure = "erasure", // Art. 17: Right to erasure
  restriction = "restriction", // Art. 18: Right to restriction
  portability = "portability", // Art. 20: Right to data portability
  objection = "objection", // Art. 21: Right to object
  information = "information", // Art. 13/14: Right to information
}

/// Status of a data subject request
enum PDMRequestStatus : string {
  draft = "draft",
  submitted = "submitted",
  processing = "processing",
  completed = "completed",
  rejected = "rejected",
  cancelled = "cancelled",
}

/// Status of a notification to a data subject
enum PDMNotificationStatus : string {
  pending = "pending",
  sent = "sent",
  delivered = "delivered",
  failed = "failed",
  read_ = "read",
}

/// Notification channel
enum PDMNotificationChannel : string {
  email = "email",
  portal = "portal",
  api = "api",
}

/// Legal basis for data processing
enum PDMLegalBasis : string {
  gdpr = "GDPR",
  ccpa = "CCPA",
  lgpd = "LGPD",
  pdpa = "PDPA",
  pipa = "PIPA",
  custom = "custom",
}

/// Status of a data subject
enum PDMSubjectStatus : string {
  active = "active",
  inactive = "inactive",
  deleted = "deleted",
}
