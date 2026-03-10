module uim.sap.pre.models.recommendation;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A single recommendation result returned to the caller.
struct PRERecommendation {
    string recommendationId;
    string userId;
    string itemId;
    string tenantId;
    string modelId;
    PRERecommendationType recommendationType;
    double score = 0.0;
    size_t rank;
    string[string] context;
    string explanation;
    string createdAt;
}

Json recommendationToJson(const ref PRERecommendation r) {
    Json j = Json.emptyObject;
    j["recommendationId"] = r.recommendationId;
    j["userId"] = r.userId;
    j["itemId"] = r.itemId;
    j["tenantId"] = r.tenantId;
    j["modelId"] = r.modelId;
    j["recommendationType"] = r.recommendationType.to!string;
    j["score"] = r.score;
    j["rank"] = cast(long) r.rank;
    {
        Json obj = Json.emptyObject;
        foreach (k, v; r.context)
            obj[k] = v;
        j["context"] = obj;
    }
    j["explanation"] = r.explanation;
    j["createdAt"] = r.createdAt;
    return j;
}
