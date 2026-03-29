/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.models.training_job;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// Tracks the status of a model-training job.
class PRETrainingJob : SAPTenantEntity {
  mixin(SAPTenantEntity!PRETrainingJob);

  string jobId;
  string modelId;
  PRETrainingStatus status = PRETrainingStatus.queued;
  size_t itemsProcessed;
  size_t usersProcessed;
  size_t interactionsProcessed;
  string startedAt;
  string completedAt;
  string errorMessage;

  override Json toJson() {
    return super.toJson
      .set("jobId", jobId)
      .set("modelId", modelId)
      .set("tenantId", tenantId)
      .set("status", status.to!string)
      .set("itemsProcessed", cast(long)itemsProcessed)
      .set("usersProcessed", cast(long)usersProcessed)
      .set("interactionsProcessed", cast(long)interactionsProcessed)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("errorMessage", errorMessage)
      .set("createdAt", createdAt);
  }
}
