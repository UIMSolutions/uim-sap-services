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
struct PRETrainingJob {
  string jobId;
  string modelId;
  UUID tenantId;
  PRETrainingStatus status = PRETrainingStatus.queued;
  size_t itemsProcessed;
  size_t usersProcessed;
  size_t interactionsProcessed;
  string startedAt;
  string completedAt;
  string errorMessage;
  string createdAt;
}

Json trainingJobToJson(const ref PRETrainingJob t) {
  return Json.emptyObject
    .set("jobId", t.jobId)
    .set("modelId", t.modelId)
    .set("tenantId", t.tenantId)
    .set("status", t.status.to!string)
    .set("itemsProcessed", cast(long)t.itemsProcessed)
    .set("usersProcessed", cast(long)t.usersProcessed)
    .set("interactionsProcessed", cast(long)t.interactionsProcessed)
    .set("startedAt", t.startedAt)
    .set("completedAt", t.completedAt)
    .set("errorMessage", t.errorMessage)
    .set("createdAt", t.createdAt);
}
