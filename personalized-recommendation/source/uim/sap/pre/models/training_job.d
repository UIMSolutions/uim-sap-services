module uim.sap.pre.models.training_job;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// Tracks the status of a model-training job.
struct PRETrainingJob {
    string jobId;
    string modelId;
    string tenantId;
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
    Json j = Json.emptyObject;
    j["jobId"] = t.jobId;
    j["modelId"] = t.modelId;
    j["tenantId"] = t.tenantId;
    j["status"] = t.status.to!string;
    j["itemsProcessed"] = cast(long) t.itemsProcessed;
    j["usersProcessed"] = cast(long) t.usersProcessed;
    j["interactionsProcessed"] = cast(long) t.interactionsProcessed;
    j["startedAt"] = t.startedAt;
    j["completedAt"] = t.completedAt;
    j["errorMessage"] = t.errorMessage;
    j["createdAt"] = t.createdAt;
    return j;
}
