/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.mapping;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/** 
  * Represents a data mapping definition used for transforming data between different formats and schemas in the context of SAP Integration Suite.
  *
  * The INTMapping struct includes metadata about the mapping, such as its name, description, source and target formats, and the actual mapping rules defined in JSON format.
  *
  * Source and Target Formats:
  * - sourceFormat: The format of the input data (e.g., xml, json, csv, idoc, edifact).
  * - targetFormat: The format of the output data after transformation (e.g., json).
  *
  * Status:
  * - draft: The mapping is still being defined and is not yet ready for use.
  * - published: The mapping is finalized and can be used in integration flows.
  * - deprecated: The mapping is outdated and should not be used for new integrations.
  *
  * Generation Method:
  * - manual: The mapping was created manually by a developer or integrator.
  * - crowdsource: The mapping was generated based on community contributions or shared mappings.
  * - ml: The mapping was generated using machine learning techniques based on sample data and desired transformations.
  * 
  * Mapping Rules:
  * The mappingRules field contains the actual transformation logic defined in JSON format. This can include field mappings, transformation functions, conditional logic, and any other rules necessary to convert data from the source format to the target format.
  * For more information on data mappings and their management, refer to the SAP Integration Suite documentation.
  * Example usage:
  *   Json request = ...; // JSON payload from API request to create a new mapping
  *   INTMapping mapping = mappingFromJson("tenant123", request); // Create a new mapping instance from the JSON request
  *   Json response = mapping.toJson(); // Convert the mapping instance to JSON for API response or storage
  * 
  * 
  * Fields:
  * - tenantId: The ID of the tenant that owns this mapping.
  * - mappingId: A unique identifier for the mapping.
  * - name: The name of the mapping.
  * - description: A brief description of the mapping.
  * - sourceFormat: The format of the input data (e.g., xml, json, csv, idoc, edifact).
  * - targetFormat: The format of the output data after transformation (e.g., json).
  * - sourceSchema: The schema definition for the source data format.
  * - targetSchema: The schema definition for the target data format.
  * - status: The current status of the mapping (e.g., draft, published, deprecated).
  * - generationMethod: The method used to create the mapping (e.g., manual, crowdsource, ml).
  * - mappingRules: A JSON object containing the actual transformation rules for converting data from the source format to the target format.
  * - createdAt: The timestamp when the mapping was created.
  * - updatedAt: The timestamp when the mapping was last updated.
  * 
  * Methods:
  * - toJson(): Converts the mapping instance into a JSON representation for API responses or storage.
  * - mappingFromJson(UUID tenantId, Json request): Creates a new mapping instance from a JSON request, generating a unique mappingId and setting the createdAt and updatedAt timestamps.   
  * 
  * Statuses:
  * - draft: The mapping is still being defined and is not yet ready for use.
  * - published: The mapping is finalized and can be used in integration flows.
  * - deprecated: The mapping is outdated and should not be used for new integrations.
  * 
  * Generation Methods:
  * - manual: The mapping was created manually by a developer or integrator.
  * - crowdsource: The mapping was generated based on community contributions or shared mappings.
  * - ml: The mapping was generated using machine learning techniques based on sample data and desired transformations.
  * 
  * For more information on data mappings and their management, refer to the SAP Integration Suite documentation.
  */
struct INTMapping {
  UUID tenantId;
  string mappingId;
  string name;
  string description;
  string sourceFormat = "xml"; // xml | json | csv | idoc | edifact
  string targetFormat = "json";
  string sourceSchema;
  string targetSchema;
  string status = "draft"; // draft | published | deprecated
  string generationMethod = "manual"; // manual | crowdsource | ml
  Json mappingRules;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["mapping_id"] = mappingId;
    j["name"] = name;
    j["description"] = description;
    j["source_format"] = sourceFormat;
    j["target_format"] = targetFormat;
    j["source_schema"] = sourceSchema;
    j["target_schema"] = targetSchema;
    j["status"] = status;
    j["generation_method"] = generationMethod;
    j["mapping_rules"] = mappingRules;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTMapping mappingFromJson(UUID tenantId, Json request) {
  INTMapping m;
  m.tenantId = UUID(tenantId);
  m.mappingId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    m.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    m.description = request["description"].get!string;
  if ("source_format" in request && request["source_format"].isString)
    m.sourceFormat = request["source_format"].get!string;
  if ("target_format" in request && request["target_format"].isString)
    m.targetFormat = request["target_format"].get!string;
  if ("source_schema" in request && request["source_schema"].isString)
    m.sourceSchema = request["source_schema"].get!string;
  if ("target_schema" in request && request["target_schema"].isString)
    m.targetSchema = request["target_schema"].get!string;
  if ("generation_method" in request && request["generation_method"].isString)
    m.generationMethod = request["generation_method"].get!string;
  if ("mapping_rules" in request)
    m.mappingRules = request["mapping_rules"];
  else
    m.mappingRules = Json.emptyObject;

  m.createdAt = Clock.currTime().toINTOExtString();
  m.updatedAt = m.createdAt;
  return m;
}
