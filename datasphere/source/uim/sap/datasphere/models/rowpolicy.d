/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.rowpolicy;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
    * Row-level security policy for a dataset
    *
    * Fields:
    * - tenantId: ID of the tenant
    * - policyId: Unique identifier for the row policy
    * - dataset: The dataset this policy applies to
    * - expression: The expression that defines the row-level security (e.g., SQL WHERE clause)
    * - updatedAt: Timestamp of the last update to this policy
    *
    * This struct represents a row-level security policy that can be applied to datasets in Datasphere. It includes the necessary information to identify the policy, the dataset it applies to, and the expression that
    * defines the security rules. The `toJson` method allows for easy serialization of the policy into JSON format for storage or transmission. 
    * 
    * Note: The actual implementation of how the expression is evaluated and enforced is beyond the scope of this struct and would be handled by the underlying data access layer in Datasphere.
    */
class DATRowPolicy : SAPTenantObject {
    mixin(SAPEntityTemplate!DATRowPolicy);

    UUID policyId;
    string dataset;
    string expression;

    override Json toJson()  {
      return super.toJson
        .set("policy_id", policyId)
        .set("dataset", dataset)
        .set("expression", expression);
    }
}