/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.agreement;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * This struct represents a trading agreement between the tenant and a partner.
  * It includes details about the agreement such as the partner, document standard, direction, status, validity period, and transaction count.
  * The toJson method allows for easy serialization of the agreement data to JSON format for API responses or storage.
  *
  * The agreementFromJson function is a helper that creates an INTAgreement instance from a JSON request, typically used when creating a new agreement via an API endpoint.
  *
  * Note: The agreementId is generated as a random UUID when creating a new agreement from JSON.
  *
  * Example usage:
  * Json request = ...; // JSON payload from API request
  * INTAgreement agreement = agreementFromJson("tenant123", request);  
  * Json response = agreement.toJson(); // Convert agreement to JSON for API response
  *
  * Document Standards:
  * - EDIFACT: A widely used international standard for electronic data interchange (EDI).
  * - X12: A standard for EDI used primarily in North America.
  * - cXML: A protocol for communication of business documents between procurement applications, e-commerce hubs, and suppliers.
  * - SAP IDoc: A standard data structure used in SAP applications for electronic data interchange.
  * Directions:
  * - inbound: Documents received from the partner.
  * - outbound: Documents sent to the partner.
  * - bidirectional: Both inbound and outbound documents are covered by the agreement.
  * Statuses:
  * - draft: The agreement is being drafted and is not yet active.
  * - active: The agreement is active and can be used for transactions.
  * - suspended: The agreement is temporarily suspended and cannot be used for transactions.
  * - terminated: The agreement is terminated and cannot be used for transactions.
  *
  * Validity Period:
  * - validFrom: The date and time when the agreement becomes valid (INTO 8601 format).
  * - validTo: The date and time when the agreement expires (INTO 8601 format).
  * Transaction Count:
  * - transactionCount: The number of transactions that have been processed under this agreement.
  * Timestamps:
  * - createdAt: The date and time when the agreement was created (INTO 8601 format).
  * - updatedAt: The date and time when the agreement was last updated (INTO 8601 format).
  *
  * This struct and its associated functions are part of the SAP Integration Suite and are used to manage trading agreements with partners.
  *
  * For more information on trading agreements and their management, refer to the SAP Integration Suite documentation.
  *
  * Fields:
  * - tenantId: The unique identifier of the tenant that owns the agreement.
  * - agreementId: The unique identifier of the agreement.
  * - partnerId: The unique identifier of the partner involved in the agreement.
  * - name: The name of the agreement.
  * - description: A brief description of the agreement.
  * - documentStandard: The standard used for the documents exchanged under this agreement (e.g., EDIFACT, X12, cXML, SAP IDoc).
  * - direction: The direction of the agreement (inbound, outbound, bidirectional).
  * - status: The current status of the agreement (draft, active, suspended, terminated).
  * - validFrom: The date and time when the agreement becomes valid (in INTO 8601 format).
  * - validTo: The date and time when the agreement expires (in INTO 8601 format).
  * - transactionCount: The number of transactions processed under this agreement.
  * - createdAt: The date and time when the agreement was created (in INTO 8601 format).
  * - updatedAt: The date and time when the agreement was last updated (in INTO 8601 format).
  *
  * Methods:
  * - toJson: Converts the agreement instance to a JSON object for easy serialization.
  * - agreementFromJson: A helper function that creates an INTAgreement instance from a JSON request, typically used when creating a new agreement via an API endpoint.
  */
struct INTAgreement {
  string tenantId;
  string agreementId;
  string partnerId;
  string name;
  string description;
  string documentStandard = "EDIFACT"; // EDIFACT | X12 | cXML | SAP IDoc
  string direction = "outbound"; // inbound | outbound | bidirectional
  string status = "draft"; // draft | active | suspended | terminated
  string validFrom;
  string validTo;
  long transactionCount = 0;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["agreement_id"] = agreementId;
    j["partner_id"] = partnerId;
    j["name"] = name;
    j["description"] = description;
    j["document_standard"] = documentStandard;
    j["direction"] = direction;
    j["status"] = status;
    j["valid_from"] = validFrom;
    j["valid_to"] = validTo;
    j["transaction_count"] = transactionCount;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTAgreement agreementFromJson(string tenantId, Json request) {
  INTAgreement a;
  a.tenantId = UUID(tenantId);
  a.agreementId = randomUUID().toString();

  if ("partner_id" in request && request["partner_id"].isString)
    a.partnerId = request["partner_id"].get!string;
  if ("name" in request && request["name"].isString)
    a.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    a.description = request["description"].get!string;
  if ("document_standard" in request && request["document_standard"].isString)
    a.documentStandard = request["document_standard"].get!string;
  if ("direction" in request && request["direction"].isString)
    a.direction = request["direction"].get!string;
  if ("valid_from" in request && request["valid_from"].isString)
    a.validFrom = request["valid_from"].get!string;
  if ("valid_to" in request && request["valid_to"].isString)
    a.validTo = request["valid_to"].get!string;

  a.createdAt = Clock.currTime().toINTOExtString();
  a.updatedAt = a.createdAt;
  return a;
}
